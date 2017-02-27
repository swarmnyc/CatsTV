//
//  TopCatVideoView.swift
//  CatsTV
//
//  Created by William Robinson on 2/15/17.
//
//

import UIKit
import AVKit

class TopCatVideoView: UIView {
  
  // Delegation
  var nextCatDelegate: CatOutputProtocol!
  
  // Subviews
  lazy var loadingCatImageView: UIImageView = {
    let imageView = UIImageView(image: #imageLiteral(resourceName: "LoadingCat"))
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  lazy var loadingGlassesImageView: UIImageView = {
    let imageView = UIImageView(image: #imageLiteral(resourceName: "LoadingGlasses"))
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  lazy var topCatPlayerLayer: AVPlayerLayer = {
    let playerLayer = AVPlayerLayer()
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
    playerLayer.needsDisplayOnBoundsChange = true
    playerLayer.cornerRadius = 10
    playerLayer.masksToBounds = true
    return playerLayer
  }()
  var nextPlayer: AVPlayer?
  var index = 1
  var playCount = 0
  
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
  
  // Property overrides
  override var canBecomeFocused: Bool {
    return true
  }
  
  func toggleLoading() {
    UIView.animate(
      withDuration: 0.1,
      delay: 0,
      options: [.curveEaseIn, .repeat, .autoreverse, .beginFromCurrentState],
      animations: {
        self.loadingCatImageView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.loadingGlassesImageView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
    })
  }
  
  // Set video
  func setVideo(_ player: AVPlayer) {
    NotificationCenter.default.removeObserver(self)
    topCatPlayerLayer.player = player
    playCount = 2
    NotificationCenter.default.addObserver(
      forName: Notification.Name.AVPlayerItemDidPlayToEndTime,
      object: topCatPlayerLayer.player!.currentItem,
      queue: OperationQueue.main
    ) { _ in
      self.playCount -= 1
      if self.playCount > 0 {
        self.topCatPlayerLayer.player!.seek(to: kCMTimeZero)
        self.topCatPlayerLayer.player!.play()
      } else {
        self.nextCatDelegate.nextCat()
      }
    }
    topCatPlayerLayer.player!.play()
  }
  
  // Setup
  func configure() {
    
    // Add views and layers
    addSubview(loadingCatImageView)
    addSubview(loadingGlassesImageView)
    layer.addSublayer(topCatPlayerLayer)
    
    // Constrain
    loadingCatImageView.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
    loadingGlassesImageView.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
}
