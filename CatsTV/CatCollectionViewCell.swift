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
  
  // Layers
  lazy var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
  lazy var loadingCatImageView = UIImageView(image: #imageLiteral(resourceName: "LoadingCat"))
  lazy var loadingGlassesImageView = UIImageView(image: #imageLiteral(resourceName: "LoadingGlasses"))
  lazy var catThumbnailImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.adjustsImageWhenAncestorFocused = true
    return imageView
  }()
  lazy var catPlayerLayer: AVPlayerLayer = {
    let playerLayer = AVPlayerLayer(player: AVPlayer())
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
    playerLayer.needsDisplayOnBoundsChange = true
    playerLayer.player!.isMuted = true
    playerLayer.isHidden = true
    return playerLayer
  }()
  let newview: UIView = {
    return UIView()
  }()
  lazy var gradientView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.black
    view.alpha = 0
    return view
  }()
  lazy var gradientMask = CAGradientLayer()
  
  // Properties
  var catPlayerItem: AVPlayerItem?
  var isLoadingCatBig = false
  
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
    setLoading()
  }
  
  // Loading new video
  func setLoading() {
    isLoadingCatBig = !isLoadingCatBig
    UIView.animate(
      withDuration: 0.4,
      delay: 0,
      options: [.curveEaseIn, .repeat, .autoreverse, .beginFromCurrentState],
      animations: {
        if self.isLoadingCatBig {
          self.loadingCatImageView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
          self.loadingGlassesImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        } else {
          self.loadingCatImageView.transform = CGAffineTransform.identity
          self.loadingGlassesImageView.transform = CGAffineTransform.identity
        }
    })
  }
  
  // Set new video
  func setVideo(with cat: Cat) {
    let catThumbnailImage = UIImage(cgImage: try! AVAssetImageGenerator(asset: AVAsset(url: cat.url)).copyCGImage(at: kCMTimeZero, actualTime: nil))
    catThumbnailImageView.image = catThumbnailImage
    
    let catPlayerItem = AVPlayerItem(url: cat.url)
    catPlayerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.new], context: nil)
    catPlayerLayer.player!.replaceCurrentItem(with: catPlayerItem)
  }
  
  func resetCatPlayer() {
    
    // TODO: fix loading animation removal
    //loadingCatImageView.layer.removeAllAnimations()
    //loadingGlassesImageView.layer.removeAllAnimations()
    
    guard catPlayerLayer.player!.currentItem != nil else { return }
    //catPlayerLayer.isHidden = true
    catPlayerLayer.player!.cancelPendingPrerolls()
    catPlayerLayer.player!.rate = 0
    catPlayerLayer.player!.currentItem!.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
    catPlayerLayer.player!.replaceCurrentItem(with: nil)
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
    catPlayerLayer.frame = contentView.frame
    catThumbnailImageView.layer.cornerRadius = 6
    
    // Add layers
    contentView.addSubview(blurView)
    contentView.addSubview(loadingCatImageView)
    contentView.addSubview(loadingGlassesImageView)
    contentView.addSubview(catThumbnailImageView)
    contentView.addSubview(gradientView)
    contentView.layer.addSublayer(catPlayerLayer)
    
    // Constrain
    blurView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    loadingCatImageView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    loadingGlassesImageView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
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
