//
//  CatCollectionViewCell.swift
//  CatsTV
//
//  Created by William Robinson on 2/14/17.
//
//

import UIKit
import SnapKit
import AVFoundation

class CatCollectionViewCell: UICollectionViewCell {
    
    // Views and layers
    lazy var catThumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()
    lazy var catPlayerLayer: AVPlayerLayer = {
        let playerLayer = AVPlayerLayer()
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerLayer.needsDisplayOnBoundsChange = true
        playerLayer.isHidden = true
        playerLayer.cornerRadius = 8
        playerLayer.masksToBounds = true
        return playerLayer
    }()
    
    // Gesture recognition
    let longPress = UILongPressGestureRecognizer()
    
    // Properties
    var cat: Cat!
    
    // Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Set playback to normal rate after a long press or any other touch event has ended
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if catPlayerLayer.player?.rate != 1 {
            catPlayerLayer.player?.rate = 1
        }
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
        guard catPlayerLayer.player == nil else {
            startPlayer()
            return
        }
        let player = AVPlayer(url: cat.url)
        player.isMuted = true
        catPlayerLayer.player = player
        NotificationCenter.default.addObserver(
            forName: Notification.Name.AVPlayerItemDidPlayToEndTime,
            object: catPlayerLayer.player!.currentItem,
            queue: OperationQueue.main
        ) { _ in
            self.catPlayerLayer.player!.seek(to: kCMTimeZero)
            self.catPlayerLayer.player!.play()
        }
        catPlayerLayer.player!.play()
        catPlayerLayer.isHidden = false
        addGestureRecognizer(longPress)
    }
    
    func startPlayer() {
        catPlayerLayer.player?.seek(to: kCMTimeZero)
        catPlayerLayer.player?.play()
    }
    
    func pausePlayer() {
        catPlayerLayer.player?.pause()
    }
    
    func hideVideo() {
        guard catPlayerLayer.player != nil else { return }
        NotificationCenter.default.removeObserver(catPlayerLayer.player!.currentItem!)
        catPlayerLayer.player = nil
        catPlayerLayer.isHidden = true
    }
    
    func decreasePlayerSpeed() {
        catPlayerLayer.player?.rate = 0.3
    }
    
    // Initial configuration
    func configure() {
        
        // Setup
        catPlayerLayer.frame = CGRect(x: 0, y: 0, width: contentView.bounds.width, height: contentView.bounds.height)
        longPress.minimumPressDuration = 0.7
        longPress.addTarget(self, action: #selector(decreasePlayerSpeed))
        
        // Add subviews and sublayers
        contentView.addSubview(catThumbnailImageView)
        contentView.layer.addSublayer(catPlayerLayer)
        
        // Constrain
        catThumbnailImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
