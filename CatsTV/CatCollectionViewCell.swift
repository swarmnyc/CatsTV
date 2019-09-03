//
//  CatCollectionViewCell.swift
//  CatsTV
//
//  Created by William Robinson on 2/14/17.
//
//

import UIKit
import SnapKit
import AVKit

class CatCollectionViewCell: UICollectionViewCell {
  
  // Views and layers
  lazy var catThumbnailImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.adjustsImageWhenAncestorFocused = true
    return imageView
  }()
  lazy var catPlayerLayer: AVPlayerLayer = {
    let playerLayer = AVPlayerLayer()
    playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
    playerLayer.needsDisplayOnBoundsChange = true
    playerLayer.isHidden = true
    return playerLayer
  }()
  lazy var gradientView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.black
    view.alpha = 0
    return view
  }()
  lazy var blurView: UIVisualEffectView = {
    let label = UILabel()
    label.text = "Loading..."
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 28, weight: UIFont.Weight.black)
    label.textColor = UIColor.white
    let effectView = UIVisualEffectView(effect: nil)
    effectView.contentView.addSubview(label)
    label.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    return effectView
  }()
  lazy var gradientMask = CAGradientLayer()
  
  // Properties
  var cat: Cat!
  var playerObserverActive = false
  
  // Initialization
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }
  
  // Observe player item status
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    guard keyPath == #keyPath(AVPlayerItem.status) else {
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
      return
    }
    guard AVPlayerItem.Status(rawValue: change![.newKey] as! Int)! == .readyToPlay else { return }
    catPlayerLayer.player!.currentItem!.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
    playerObserverActive = false
    catPlayerLayer.player!.play()
    catPlayerLayer.isHidden = false
  }
  
  // Reset cell
  override func prepareForReuse() {
    super.prepareForReuse()
    hideVideo()
  }
  
  // Set thumbnail image
  func setThumbnail() {
    catThumbnailImageView.image = cat.image
  }
  
  // Set video
  func setVideo() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      guard self.isFocused, self.catPlayerLayer.player == nil else { return }
      let player = AVPlayer(url: self.cat.url)
      player.isMuted = true
      self.catPlayerLayer.player = player
      self.catPlayerLayer.player!.currentItem!.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: .new, context: nil)
      self.playerObserverActive = true
    }
  }
  // Hide and remove video
  func hideVideo() {
    guard playerObserverActive else { return }
    playerObserverActive = false
    catPlayerLayer.player!.currentItem!.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
    if !catPlayerLayer.isHidden {
      catPlayerLayer.isHidden = true
    }
    catPlayerLayer.player = nil
  }
  
  func pausePlayer() {
    guard playerObserverActive else { return }
    playerObserverActive = false
    catPlayerLayer.player!.currentItem!.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
    catPlayerLayer.player!.pause()
  }
  
  func startPlayer() {
    catPlayerLayer.player?.seek(to: CMTime.zero)
    catPlayerLayer.player?.play()
  }
  
  // Display message when additional cats are being retrieved
  func showLoadingMessage() {
    guard blurView.effect == nil else { return }
    contentView.addSubview(blurView)
    blurView.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.width.height.equalToSuperview().multipliedBy(1.4)
    }
    blurView.effect = UIBlurEffect(style: .light)
  }
  
  // Hide and remove loading message once cats have been stored
  func hideLoadingMessage() {
    guard blurView.effect != nil else { return }
    blurView.effect = nil
    blurView.removeFromSuperview()
  }
  
  // Initial configuration
  func configure() {
    
    // Setup
    CALayer.shadow(self)
    gradientMask.frame = contentView.bounds
    gradientMask.startPoint = CGPoint(x: 0, y: 0.5)
    gradientMask.endPoint = CGPoint(x: 1, y: 0.5)
    gradientMask.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
    gradientView.layer.mask = gradientMask
    catPlayerLayer.frame = CGRect(
      x: -contentView.frame.width * 0.155,
      y: -contentView.frame.height * 0.155,
      width: contentView.frame.width * 1.31,
      height: contentView.frame.height * 1.31)
    
    // Add layers
    contentView.addSubview(catThumbnailImageView)
    contentView.layer.addSublayer(catPlayerLayer)
    contentView.addSubview(gradientView)
    
    // Constrain
    catThumbnailImageView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    gradientView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  // ••••••••••
  
  //  func increaseGradient(_ count: Int) {
  //    guard gradientMask != nil, gradientView.alpha < 1 else { return }
  //    var adjustedCount = count
  //    if Double(gradientView.alpha) + Double(count) / 10 > 1 {
  //      adjustedCount = Int(1 - Double(gradientView.alpha)) * 10
  //    }
  //
  //    layoutIfNeeded()
  //    UIView.animateKeyframes(
  //      withDuration: Double(adjustedCount) / 10,
  //      delay: 0,
  //      options: .allowUserInteraction,
  //      animations: {
  //        for i in 0..<adjustedCount {
  //          UIView.addKeyframe(
  //            withRelativeStartTime: Double(i) / 10,
  //            relativeDuration: 0.1,
  //            animations: {
  //              self.gradientView.alpha += 0.1
  //              self.layoutIfNeeded()
  //          })
  //        }
  //    })
  //  }
  //
  //  func reduceGradient(_ count: Int) {
  //    guard gradientMask != nil, gradientView.alpha > 0.6  else { return }
  //    var adjustedCount = count
  //    if Double(gradientView.alpha) + Double(count) / 10 < 0.6 {
  //      adjustedCount = Int(Double(gradientView.alpha) - 0.6) * 10
  //    }
  //
  //    layoutIfNeeded()
  //    UIView.animateKeyframes(
  //      withDuration: Double(adjustedCount) / 10,
  //      delay: 0,
  //      options: .allowUserInteraction,
  //      animations: {
  //        for i in 0..<adjustedCount {
  //          UIView.addKeyframe(
  //            withRelativeStartTime: Double(i) / 10,
  //            relativeDuration: 0.1,
  //            animations: {
  //              self.gradientView.alpha -= 0.1
  //              self.layoutIfNeeded()
  //          })
  //        }
  //    })
  //  }
  
  // ••••••••••
  
}
