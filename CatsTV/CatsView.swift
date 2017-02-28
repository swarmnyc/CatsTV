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
    label.font = UIFont.systemFont(ofSize: 32, weight: UIFontWeightBlack)
    label.textColor = UIColor.white
    return label
  }()
  lazy var catsCollectionView = CatsCollectionView()
  lazy var launchTransitionImageView: UIImageView? = UIImageView(image: #imageLiteral(resourceName: "LaunchSplash"))
  
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
  
  // Presses
  override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
    if inputDelegate.isFullScreen, (presses.first?.type == UIPressType.menu || presses.first?.type == UIPressType.select) {
      makeRegularScreen()
    } else {
      super.pressesBegan(presses, with: event)
    }
  }

  override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
    super.didUpdateFocus(in: context, with: coordinator)
    inputDelegate.userDidInteract()
    coordinator.addCoordinatedAnimations({
      self.topCatVideoView.layer.shadowOpacity = self.topCatVideoView.isFocused ? 1 : 0.7
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
          self.layoutIfNeeded()
      })
    })
  }
  
  func addDelegates(_ inputDelegate: CatInputProtocol) {
    self.inputDelegate = inputDelegate
    topCatVideoView.inputDelegate = inputDelegate
    catsCollectionView.inputDelegate = inputDelegate
    musicCatButton.inputDelegate = inputDelegate
  }
  
  func animateFromLaunch() {
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
  
  // Adjustments after frames have been defined on screen
  func makeAdjustmentsAfterInitialLayout() {
    guard topCatVideoView.topCatPlayerLayer.frame == CGRect.zero else { return }
    topCatVideoView.topCatPlayerLayer.frame = topCatVideoView.bounds
    topCatVideoView.fullScreenFrame =
      CGRect(x: -topCatVideoView.frame.minX,
             y: -topCatVideoView.frame.minY,
             width: UIScreen.main.bounds.width,
             height: UIScreen.main.bounds.height)
    CALayer.shadow(topCatVideoView)
    CALayer.shadow(musicCatButton)
    CALayer.shadow(upNextLabel)
  }
  
  // Toggle top cat video size
  func makeFullScreen() {
    topCatVideoView.isUserInteractionEnabled = false
    blurView.isHidden = false
    blackView.isHidden = false
    UIView.animateKeyframes(
      withDuration: 0.8,
      delay: 0,
      options: [],
      animations: {
        UIView.addKeyframe(
          withRelativeStartTime: 0,
          relativeDuration: 0.6,
          animations: {
            self.topCatVideoView.layer.shadowColor = UIColor.black.cgColor
            self.blurView.effect = UIBlurEffect(style: .dark)
            self.musicCatButtonRight.update(offset: self.musicCatButton.frame.width)
            self.layoutIfNeeded()
        })
        UIView.addKeyframe(
          withRelativeStartTime: 0.1,
          relativeDuration: 0.8,
          animations: {
            self.blackView.alpha = 1
        })
        UIView.addKeyframe(
          withRelativeStartTime: 0,
          relativeDuration: 1,
          animations: {
            self.topCatVideoView.topCatPlayerLayer.frame = self.topCatVideoView.fullScreenFrame
            self.layoutIfNeeded()
        })
    }) { _ in
      self.topCatVideoView.isUserInteractionEnabled = true
      self.musicCatButton.isUserInteractionEnabled = false
      self.catsCollectionView.isUserInteractionEnabled = false
    }
  }
  
  func makeRegularScreen() {
    topCatVideoView.isUserInteractionEnabled = false
    UIView.animateKeyframes(
      withDuration: 0.7,
      delay: 0,
      options: [],
      animations: {
        UIView.addKeyframe(
          withRelativeStartTime: 0,
          relativeDuration: 0.8,
          animations: {
            self.musicCatButtonRight.update(offset: self.musicCatButton.frame.width - 195)
            self.blurView.effect = nil
            self.blackView.alpha = 0
            self.layoutIfNeeded()
        })
        UIView.addKeyframe(
          withRelativeStartTime: 0.7, relativeDuration: 0.3, animations: {
            self.topCatVideoView.layer.shadowColor = UIColor.themeGreen.cgColor
        })
        UIView.addKeyframe(
          withRelativeStartTime: 0,
          relativeDuration: 1,
          animations: {
            self.topCatVideoView.topCatPlayerLayer.frame = self.topCatVideoView.bounds
            self.layoutIfNeeded()
        })
    }) { _ in
      self.blurView.isHidden = true
      self.blackView.isHidden = true
      let item = self.topCatVideoView.index + (self.topCatVideoView.index + 1 < self.inputDelegate.catsCount ? 1 : 0)
      self.catsCollectionView.scrollToItem(at: IndexPath(item: item, section: 0), at: .left, animated: true)
      self.topCatVideoView.isUserInteractionEnabled = true
      self.musicCatButton.isUserInteractionEnabled = true
      self.catsCollectionView.isUserInteractionEnabled = true
    }
  }
  
  // Initial configuration
  func configure() {
    
    // Add subviews
    addSubview(backgroundImageView)
    addSubview(musicCatButton)
    addSubview(upNextLabel)
    addSubview(catsCollectionView)
    addSubview(blurView)
    addSubview(blackView)
    addSubview(topCatVideoView)
    addSubview(launchTransitionImageView!)
    
    // Constrain subviews
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
      $0.width.height.equalToSuperview().dividedBy(1.65)
    }
    launchTransitionImageView?.snp.makeConstraints {
      $0.edges.edges.equalToSuperview()
    }
  }
}

