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
  lazy var topCatVideoView = TopCatVideoView()
  lazy var upNextLabel: UILabel = {
    let label = UILabel()
    label.text = "Up next..."
    label.font = UIFont.systemFont(ofSize: 36, weight: UIFontWeightBlack)
    label.textColor = UIColor.white
    label.alpha = 0
    return label
  }()
  lazy var catsCollectionView: CatsCollectionView = {
    let collectionView = CatsCollectionView()
    collectionView.alpha = 0
    collectionView.decelerationRate = UIScrollViewDecelerationRateFast
    return collectionView
  }()
  lazy var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
  lazy var launchTransitionImageView: UIImageView? = UIImageView(image: #imageLiteral(resourceName: "LaunchSplash"))
  let padding: CGFloat = 100
  lazy var musicCatButton: UIButton = {
    let button = UIButton()
    button.setImage(#imageLiteral(resourceName: "MusicCat"), for: .normal)
    return button
  }()
  
  // Constraints
  var topCatVideoViewCenterX: Constraint!
  var musicCatButtonRight: Constraint!
  var launchTransitionImageViewCenterY: Constraint!
  
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
  
  override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
    super.didUpdateFocus(in: context, with: coordinator)
    coordinator.addCoordinatedAnimations({
      self.topCatVideoView.transform = self.topCatVideoView.isFocused ? CGAffineTransform(scaleX: 1.05, y: 1.05) : CGAffineTransform.identity
      self.topCatVideoView.layer.shadowOpacity = self.topCatVideoView.isFocused ? 1 : 0.7
      UIView.animate(
        withDuration: 0.8,
        delay: 0,
        usingSpringWithDamping: 0.6,
        initialSpringVelocity: 1,
        options: [.overrideInheritedDuration, .allowUserInteraction],
        animations: {
          self.musicCatButtonRight.update(offset: (self.musicCatButton.isFocused ? 50 : #imageLiteral(resourceName: "MusicCat").size.width - 195))
          self.layoutIfNeeded()
      })
    })
  }
  
  // Initial configuration
  func configure() {
    
    // Setup
    
    
    // Add subviews
    addSubview(backgroundImageView)
    addSubview(upNextLabel)
    addSubview(catsCollectionView)
    addSubview(topCatVideoView)
    addSubview(musicCatButton)
    addSubview(blurView)
    addSubview(launchTransitionImageView!)
    
    // Constrain subviews
    backgroundImageView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    catsCollectionView.snp.makeConstraints {
      $0.bottom.equalToSuperview()
      $0.centerX.equalToSuperview()
      $0.width.equalToSuperview().offset(-padding * 2)
      $0.height.equalTo(catsCollectionView.itemSize.height + catsCollectionView.spacing * 2)
    }
    upNextLabel.snp.makeConstraints {
      $0.left.equalTo(catsCollectionView)
      $0.bottom.equalTo(catsCollectionView.snp.top).offset(30)
    }
    topCatVideoView.snp.makeConstraints {
      topCatVideoViewCenterX = $0.centerX.equalToSuperview().constraint
      $0.centerY.equalToSuperview().dividedBy(1.25)
      $0.width.height.equalToSuperview().dividedBy(1.65)
    }
    musicCatButton.snp.makeConstraints {
      musicCatButtonRight = $0.right.equalToSuperview().offset(#imageLiteral(resourceName: "MusicCat").size.width - 195).constraint
      $0.centerY.equalToSuperview()
    }
    blurView.snp.makeConstraints {
      $0.edges.equalToSuperview()
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
      withDuration: 1,
      delay: 0,
      options: .curveEaseInOut,
      animations: {
        self.launchTransitionImageViewCenterY.update(offset: self.launchTransitionImageView!.frame.height)
        self.launchTransitionImageView!.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        self.blurView.effect = nil
        self.layoutIfNeeded()
    }) { _ in
      self.launchTransitionImageView!.snp.removeConstraints()
      self.launchTransitionImageView!.removeFromSuperview()
      self.launchTransitionImageView = nil
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
    let fullFrame = CGRect(
      x: -topCatVideoView.frame.minX,
      y: -topCatVideoView.frame.minY,
      width: UIScreen.main.bounds.width,
      height: UIScreen.main.bounds.height)
    UIView.animate(
      withDuration: 0.5,
      animations: {
        self.topCatVideoView.topCatPlayerLayer.frame = self.isFullScreen ? fullFrame : self.topCatVideoView.bounds
        self.layoutIfNeeded()
    })
  }
  
  @objc func appleMusicButtonTouched() {
    let url = URL(string: "music:")!
    if UIApplication.shared.canOpenURL(url) {
      UIApplication.shared.open(url, options: [:])
    }
  }
}

