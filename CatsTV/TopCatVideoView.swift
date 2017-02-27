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
      if self.playCount > 0 {
        self.topCatPlayerLayer.player!.seek(to: kCMTimeZero)
        self.topCatPlayerLayer.player!.play()
        self.playCount -= 1
      } else {
        self.nextCatDelegate.nextCat()
      }
    }
    topCatPlayerLayer.player!.play()
  }
  
  // Setup
  func configure() {
    layer.addSublayer(topCatPlayerLayer)
  }
}
