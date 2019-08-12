//
//  CatsView.swift
//  CatsTV
//
//  Created by William Robinson on 2/14/17.
//
//

import UIKit
import SnapKit
import AVKit

class CatsView: UIView {
  
  // Delegation
  weak var inputDelegate: CatInputProtocol!
  
  // View and layers
  lazy var backgroundImageView: UIImageView = {
    let imageView = UIImageView(image: #imageLiteral(resourceName: "Background"))
    imageView.contentMode = .scaleAspectFill
    return imageView
  }()
  lazy var musicCatButton = MusicCatButton()
  lazy var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
  lazy var blackView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.black
    view.alpha = 0
    view.isHidden = true
    return view
  }()
  lazy var topCatVideoView = TopCatVideoView()
  lazy var upNextLabel: UILabel = {
    let label = UILabel()
    label.text = "Up next..."
    label.font = UIFont.systemFont(ofSize: 32, weight: UIFont.Weight.black)
    label.textColor = UIColor.white
    return label
  }()
  lazy var catsCollectionView = CatsCollectionView()
  lazy var launchTransitionImageView: UIImageView? = UIImageView(image: #imageLiteral(resourceName: "LaunchSplash"))
  
  // Gesture recognition
  lazy var rightSwipeGestureReconizer: UISwipeGestureRecognizer = {
    let recognizer = UISwipeGestureRecognizer()
    recognizer.direction = .right
    return recognizer
  }()
  lazy var leftSwipeGestureReconizer: UISwipeGestureRecognizer = {
    let recognizer = UISwipeGestureRecognizer()
    recognizer.direction = .left
    return recognizer
  }()
  
  // Constraints
  var topCatVideoViewCenterX: Constraint!
  var musicCatButtonRight: Constraint!
  
  // Initialization
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  convenience init() {
    self.init(frame: CGRect.zero)
    configure()
  }
  
  // Focus
  override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
    super.didUpdateFocus(in: context, with: coordinator)
    inputDelegate.userDidInteract()
    coordinator.addCoordinatedAnimations({
      UIView.animate(
        withDuration: 0.8,
        delay: 0,
        usingSpringWithDamping: 0.6,
        initialSpringVelocity: 1,
        options: [.allowUserInteraction, .overrideInheritedDuration, .overrideInheritedOptions],
        animations: {
          self.musicCatButtonRight.update(offset: (self.musicCatButton.isFocused ? 50 : self.musicCatButton.frame.width - 195))
          self.topCatVideoViewCenterX.update(offset: self.musicCatButton.isFocused ? -self.musicCatButton.frame.width / 4 : 0)
          self.topCatVideoView.transform = self.topCatVideoView.isFocused ? CGAffineTransform(scaleX: 1.05, y: 1.05) : (self.musicCatButton.isFocused ? CGAffineTransform(scaleX: 0.9, y: 0.9) : CGAffineTransform.identity)
          self.topCatVideoView.layer.shadowColor = self.topCatVideoView.isFocused ? UIColor.black.cgColor : UIColor.themeGreen.cgColor
          self.layoutIfNeeded()
      })
    })
  }
  
  // User interaction
  override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
    if inputDelegate.isFullScreen, (presses.first?.type == UIPress.PressType.menu || presses.first?.type == UIPress.PressType.select) {
      inputDelegate.toggleFullScreen()
    } else {
      super.pressesBegan(presses, with: event)
    }
  }
    @objc func swipedRight() {
    NotificationCenter.default.removeObserver(topCatVideoView.topCatPlayerLayer.player!.currentItem!)
    inputDelegate.nextCat()
  }
    @objc func swipedLeft() {
    NotificationCenter.default.removeObserver(topCatVideoView.topCatPlayerLayer.player!.currentItem!)
    inputDelegate.previousCat()
  }
  
  // Delegation setup
  func addDelegates(_ inputDelegate: CatInputProtocol) {
    self.inputDelegate = inputDelegate
    topCatVideoView.inputDelegate = inputDelegate
    catsCollectionView.inputDelegate = inputDelegate
    musicCatButton.inputDelegate = inputDelegate
  }
  
  // Animations on app launch
  func animateOnLaunch() {
    UIView.animate(
      withDuration: 1.5,
      delay: 0,
      options: .curveEaseInOut,
      animations: {
        self.launchTransitionImageView!.alpha = 0
        self.blurView.effect = nil
        self.layoutIfNeeded()
    }) { _ in
      self.launchTransitionImageView!.removeFromSuperview()
      self.launchTransitionImageView = nil
      self.blurView.isHidden = true
      self.topCatVideoView.prepareForLoading()
    }
  }
  
  // Adjustments after frames have been defined by Auto Layout constraints
  func makeAdjustmentsAfterInitialLayout() {
    guard !inputDelegate.didPerformInitialLayout else { return }
    topCatVideoView.topCatPlayerLayer.frame = topCatVideoView.bounds
    topCatVideoView.fullScreenFrame =
      CGRect(x: -topCatVideoView.frame.minX,
             y: -topCatVideoView.frame.minY,
             width: UIScreen.main.bounds.width,
             height: UIScreen.main.bounds.height)
    CALayer.shadow(topCatVideoView)
    CALayer.shadow(musicCatButton)
    CALayer.shadow(upNextLabel)
    inputDelegate.didPerformInitialLayout = true
  }
  
  // Resize top cat video to fill screen
  func makeFullScreen() {
    blurView.isHidden = false
    blackView.isHidden = false
    topCatVideoView.isUserInteractionEnabled = false
    catsCollectionView.isUserInteractionEnabled = false
    musicCatButton.isUserInteractionEnabled = false
    UIView.animateKeyframes(
      withDuration: 0.8,
      delay: 0,
      options: [],
      animations: {
        UIView.addKeyframe(
          withRelativeStartTime: 0,
          relativeDuration: 0.2,
          animations: {
            self.topCatVideoView.transform = CGAffineTransform.identity
        })
        UIView.addKeyframe(
          withRelativeStartTime: 0,
          relativeDuration: 0.6,
          animations: {
            self.topCatVideoView.layer.shadowColor = UIColor.black.cgColor
            self.blurView.effect = UIBlurEffect(style: .dark)
            self.musicCatButtonRight.update(offset: 50)
            self.layoutIfNeeded()
        })
        UIView.addKeyframe(
          withRelativeStartTime: 0.1,
          relativeDuration: 0.8,
          animations: {
            self.blackView.alpha = 1
        })
        UIView.addKeyframe(
          withRelativeStartTime: 0.2,
          relativeDuration: 0.8,
          animations: {
            self.topCatVideoView.topCatPlayerLayer.frame = self.topCatVideoView.fullScreenFrame
            self.topCatVideoViewCenterX.update(offset: 0)
            self.layoutIfNeeded()
        })
    })
  }
  
  // Set top cat video to original size
  func makeRegularScreen() {
    UIView.animateKeyframes(
      withDuration: 0.7,
      delay: 0,
      options: [],
      animations: {
        UIView.addKeyframe(
          withRelativeStartTime: 0,
          relativeDuration: 0.8,
          animations: {
            self.topCatVideoView.topCatPlayerLayer.frame = self.topCatVideoView.bounds
            self.topCatVideoViewCenterX.update(offset: self.musicCatButton.isFocused ? -self.musicCatButton.frame.width / 4 : 0)
            self.musicCatButtonRight.update(offset: (self.musicCatButton.isFocused ? 50 : self.musicCatButton.frame.width - 195))
            self.blurView.effect = nil
            self.blackView.alpha = 0
            self.layoutIfNeeded()
        })
        UIView.addKeyframe(
          withRelativeStartTime: 0.8, relativeDuration: 0.2, animations: {
            self.topCatVideoView.transform = self.topCatVideoView.isFocused ? CGAffineTransform(scaleX: 1.05, y: 1.05) : (self.musicCatButton.isFocused ? CGAffineTransform(scaleX: 0.9, y: 0.9) : CGAffineTransform.identity)
            self.topCatVideoView.layer.shadowColor = self.topCatVideoView.isFocused ? UIColor.black.cgColor : UIColor.themeGreen.cgColor
        })
    }) { _ in
      self.blurView.isHidden = true
      self.blackView.isHidden = true
      let item = self.topCatVideoView.index + (self.topCatVideoView.index + 1 < self.inputDelegate.catsCount ? 1 : 0)
      self.catsCollectionView.remembersLastFocusedIndexPath = false
      self.catsCollectionView.scrollToItem(at: IndexPath(item: item, section: 0), at: .left, animated: true)
      self.topCatVideoView.isUserInteractionEnabled = true
      self.catsCollectionView.isUserInteractionEnabled = true
      self.musicCatButton.isUserInteractionEnabled = true
    }
  }
  
  // Set gesture recognition for regular and full screen modes
  func toggleGestureRecognizersForScreenStatus() {
    if inputDelegate.isFullScreen {
      topCatVideoView.removeGestureRecognizer(topCatVideoView.screenTapGestureRecognizer)
      addGestureRecognizer(leftSwipeGestureReconizer)
      addGestureRecognizer(rightSwipeGestureReconizer)
    } else {
      topCatVideoView.addGestureRecognizer(topCatVideoView.screenTapGestureRecognizer)
      removeGestureRecognizer(leftSwipeGestureReconizer)
      removeGestureRecognizer(rightSwipeGestureReconizer)
    }
  }
  
  // Initial configuration
  func configure() {
    
    // Setup
    isUserInteractionEnabled = false
    
    // Add targets
    rightSwipeGestureReconizer.addTarget(self, action: #selector(swipedRight))
    leftSwipeGestureReconizer.addTarget(self, action: #selector(swipedLeft))
    
    // Add subviews and sublayers
    addSubview(backgroundImageView)
    addSubview(musicCatButton)
    addSubview(upNextLabel)
    addSubview(catsCollectionView)
    addSubview(blurView)
    addSubview(blackView)
    addSubview(topCatVideoView)
    addSubview(launchTransitionImageView!)
    
    // Add constraints
    backgroundImageView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    musicCatButton.snp.makeConstraints {
      musicCatButtonRight = $0.right.equalToSuperview().offset(#imageLiteral(resourceName: "MusicCat").size.width - 195).constraint
      $0.centerY.equalTo(topCatVideoView)
    }
    catsCollectionView.snp.makeConstraints {
      $0.bottom.equalToSuperview().offset(-60)
      $0.centerX.equalToSuperview()
      $0.width.equalToSuperview().offset(-180)
      $0.height.equalTo(catsCollectionView.itemSize.height)
    }
    upNextLabel.snp.makeConstraints {
      $0.left.equalTo(catsCollectionView)
      $0.bottom.equalTo(catsCollectionView.snp.top).offset(-50)
    }
    blurView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    blackView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    topCatVideoView.snp.makeConstraints {
      topCatVideoViewCenterX = $0.centerX.equalToSuperview().constraint
      $0.centerY.equalToSuperview().dividedBy(1.25)
      $0.width.equalToSuperview()
      $0.height.equalToSuperview().dividedBy(1.65)
    }
    launchTransitionImageView?.snp.makeConstraints {
      $0.edges.edges.equalToSuperview()
    }
  }
}

