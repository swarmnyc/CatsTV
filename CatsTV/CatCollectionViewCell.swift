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
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
    playerLayer.needsDisplayOnBoundsChange = true
    return playerLayer
  }()
  lazy var gradientView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.black
    view.alpha = 0
    return view
  }()
  lazy var gradientMask = CAGradientLayer()
  
  // Properties
  var cat: Cat!
  
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
    
    if AVPlayerItemStatus(rawValue: change![.newKey] as! Int)! == .readyToPlay {
      
      // TODO: show when playable
      
    }
  }
  
  // Reset cell
  override func prepareForReuse() {
    super.prepareForReuse()
    resetCatPlayer()
  }
  
  // Set new video
  func setThumbnail() {
    catThumbnailImageView.image = cat.image
  }
  
  func resetCatPlayer() {
    if catPlayerLayer.player != nil {
      catPlayerLayer.player = nil
    }
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
      x: -contentView.frame.width * 0.2,
      y: -contentView.frame.height * 0.2,
      width: contentView.frame.width * 1.4,
      height: contentView.frame.height * 1.4)
    
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
