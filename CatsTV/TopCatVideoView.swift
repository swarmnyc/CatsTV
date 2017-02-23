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
  
  // Subviews
  lazy var topCatPlayerLayer: AVPlayerLayer = {
    let playerLayer = AVPlayerLayer(player: AVPlayer())
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
    playerLayer.needsDisplayOnBoundsChange = true
    playerLayer.cornerRadius = 10
    playerLayer.masksToBounds = true
    return playerLayer
  }()
  
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

  // Setup
  func configure() {
    layer.addSublayer(topCatPlayerLayer)
  }
}
