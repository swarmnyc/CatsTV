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
  
  // View and layers
  lazy var backgroundImageView: UIImageView = {
    let imageView = UIImageView(image: #imageLiteral(resourceName: "Background"))
    imageView.contentMode = .scaleAspectFill
    return imageView
  }()
  lazy var musicCatButton: UIButton = {
    let button = UIButton()
    button.setImage(#imageLiteral(resourceName: "MusicCat"), for: .normal)
    return button
  }()
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
    label.font = UIFont.systemFont(ofSize: 36, weight: UIFontWeightBlack)
    label.textColor = UIColor.white
    return label
  }()
  lazy var catsCollectionView: CatsCollectionView = {
    let collectionView = CatsCollectionView()
    
    return collectionView
  }()
  
  lazy var launchTransitionImageView: UIImageView? = UIImageView(image: #imageLiteral(resourceName: "LaunchSplash"))
  
  // Constraints
  var topCatVideoViewCenterX: Constraint!
  var musicCatButtonRight: Constraint!
  var launchTransitionImageViewCenterY: Constraint!
  
  // Constants
  let padding: CGFloat = 100
  
  // Properties
  var isFullScreen = false
  var isScrolling = false
  
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
    if presses.first?.type == UIPressType.menu, isFullScreen {
      toggleFullScreen()
    } else {
      super.pressesBegan(presses, with: event)
    }
  }
  
  override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
    return !isFullScreen
  }
  
  override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
    super.didUpdateFocus(in: context, with: coordinator)
    
    print("updated focus")
    if isFocused { print("rootview") }
    print(catsCollectionView.canBecomeFocused)
    if topCatVideoView.isFocused { print("topcatfocused") }
    if catsCollectionView.isFocused { print("collectionviewfocused") }
    
    coordinator.addCoordinatedAnimations({
      self.topCatVideoView.layer.shadowOpacity = self.topCatVideoView.isFocused ? 1 : 0.7
      UIView.animate(
        withDuration: 0.8,
        delay: 0,
        usingSpringWithDamping: 0.6,
        initialSpringVelocity: 1,
        options: [.overrideInheritedDuration, .allowUserInteraction],
        animations: {
          self.musicCatButtonRight.update(offset: (self.musicCatButton.isFocused ? 50 : self.musicCatButton.frame.width - 195))
          self.topCatVideoViewCenterX.update(offset: self.musicCatButton.isFocused ? -self.musicCatButton.frame.width / 4 : 0)
          self.topCatVideoView.transform = self.topCatVideoView.isFocused ? CGAffineTransform(scaleX: 1.05, y: 1.05) : (self.musicCatButton.isFocused ? CGAffineTransform(scaleX: 0.9, y: 0.9) : CGAffineTransform.identity)
          self.layoutIfNeeded()
      })
    })
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
      $0.centerY.equalToSuperview()
    }
    catsCollectionView.snp.makeConstraints {
      $0.bottom.equalToSuperview().offset(-60)
      $0.centerX.equalToSuperview()
      $0.width.equalToSuperview().offset(-padding * 2)
      $0.height.equalTo(catsCollectionView.itemSize.height)
    }
    upNextLabel.snp.makeConstraints {
      $0.left.equalTo(catsCollectionView)
      $0.bottom.equalTo(catsCollectionView.snp.top).offset(-30)
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
      $0.centerX.width.height.equalToSuperview()
      launchTransitionImageViewCenterY = $0.centerY.equalToSuperview().constraint
    }
  }
  
  func addTargets() {
    topCatVideoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleFullScreen)))
    musicCatButton.addTarget(self, action: #selector(appleMusicButtonTouched), for: .primaryActionTriggered)
  }
  
  func animateFromLaunch() {
    UIView.animate(
      withDuration: 1.5,
      delay: 0,
      options: .curveEaseInOut,
      animations: {
        self.launchTransitionImageViewCenterY.update(offset: self.launchTransitionImageView!.frame.height)
        self.launchTransitionImageView!.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        self.launchTransitionImageView!.alpha = 0.3
        self.blurView.effect = nil
        self.layoutIfNeeded()
    }) { _ in
      self.launchTransitionImageView!.snp.removeConstraints()
      self.launchTransitionImageView!.removeFromSuperview()
      self.launchTransitionImageView = nil
      self.blurView.isHidden = true
    }
  }
  
  // Adjustments after frames have been defined on screen
  func makeAdjustmentsAfterInitialLayout() {
    guard topCatVideoView.topCatPlayerLayer.frame == CGRect.zero else { return }
    topCatVideoView.topCatPlayerLayer.frame = topCatVideoView.bounds
    CALayer.shadow(topCatVideoView)
    CALayer.shadow(musicCatButton)
    CALayer.shadow(upNextLabel)
  }
  
  // Animations
  func prepareForCatDisplay() {
    layoutIfNeeded()
    UIView.animateKeyframes(
      withDuration: 2,
      delay: 0,
      options: .calculationModeCubic,
      animations: {
        UIView.addKeyframe(
          withRelativeStartTime: 1,
          relativeDuration: 1,
          animations: {
            self.upNextLabel.alpha = 1
            self.catsCollectionView.alpha = 1
            self.layoutIfNeeded()
        })
    })
  }
  
  func showCats() {
    let topPlayer = topCatVideoView.topCatPlayerLayer.player!
    let topPlayerItem = AVPlayerItem(url: self.catsCollectionView.cats.first!.url)
    DispatchQueue.main.async {
      topPlayer.replaceCurrentItem(with: topPlayerItem)
      self.catsCollectionView.reloadData()
      self.prepareForCatDisplay()
      NotificationCenter.default.addObserver(
        forName: Notification.Name.AVPlayerItemDidPlayToEndTime,
        object: topPlayer.currentItem,
        queue: OperationQueue.main
      ) { _ in
        topPlayer.seek(to: kCMTimeZero)
        topPlayer.play()
      }
      topPlayer.play()
    }
  }
  
  @objc func toggleFullScreen() {
    isFullScreen = !isFullScreen
    let fullFrame = CGRect(x: -topCatVideoView.frame.minX,
                           y: -topCatVideoView.frame.minY,
                           width: UIScreen.main.bounds.width,
                           height: UIScreen.main.bounds.height)
    blurView.isHidden = false
    blackView.isHidden = false
    topCatVideoView.layer.shadowOpacity = 0
    UIView.animateKeyframes(
      withDuration: isFullScreen ? 0.8 : 0.6,
      delay: 0,
      options: [],
      animations: {
        UIView.addKeyframe(
          withRelativeStartTime: 0,
          relativeDuration: self.isFullScreen ? 0.3 : 0.8,
          animations: {
            self.musicCatButtonRight.update(offset: self.isFullScreen ? self.musicCatButton.frame.width : self.musicCatButton.frame.width - 195)
            self.blurView.effect = self.isFullScreen ? UIBlurEffect(style: .dark) : nil
            self.blackView.alpha = self.isFullScreen ? 1 : 0
            self.layoutIfNeeded()
        })
        UIView.addKeyframe(
          withRelativeStartTime: 0,
          relativeDuration: 1,
          animations: {
            self.topCatVideoView.topCatPlayerLayer.frame = self.isFullScreen ? fullFrame : self.topCatVideoView.bounds
            self.layoutIfNeeded()
        })
    }) { _ in
      if !self.isFullScreen {
        self.blurView.isHidden = true
        self.blackView.isHidden = true
        self.topCatVideoView.layer.shadowOpacity = 1
      }
    }
  }
  
  @objc func appleMusicButtonTouched() {
    let url = URL(string: "music:")!
    if UIApplication.shared.canOpenURL(url) {
      UIApplication.shared.open(url, options: [:])
    }
  }
}

