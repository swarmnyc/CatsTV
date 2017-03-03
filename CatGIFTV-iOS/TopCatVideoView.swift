//
//  TopCatVideoView.swift
//  CatsTV
//
//  Created by William Robinson on 3/2/17.
//
//

import UIKit
import SnapKit
import AVFoundation

class TopCatVideoView: UIView {
    
    // Delegation
    weak var inputDelegate: CatInputProtocol!
    
    // Views and layers
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
        return playerLayer
    }()
    var previousPlayer: AVPlayer?
    var nextPlayer: AVPlayer?
    var index = 0
    var playCount = 0
    
    // Gesture recognition
    lazy var screenTapGestureRecognizer = UITapGestureRecognizer()
    
    // Constraints
    var loadingCatImageViewWidth: Constraint!
    var loadingGlassesImageViewWidth: Constraint!
    
    // Constants
    var fullScreenFrame: CGRect!
    
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
    
    // User interaction
    func screenTapped() {
        inputDelegate.toggleFullScreen()
    }
    
    // Prepare for video loading
    func prepareForLoading() {
        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 3,
            options: .curveEaseIn,
            animations: {
                self.loadingCatImageViewWidth.update(offset: #imageLiteral(resourceName: "LoadingCat").size.width)
                self.loadingGlassesImageViewWidth.update(offset: #imageLiteral(resourceName: "LoadingGlasses").size.width)
                self.layoutIfNeeded()
        }) { _ in
            self.setLoading()
        }
    }
    
    // Start loading animation
    func setLoading() {
        UIView.animateKeyframes(
            withDuration: 1,
            delay: 0,
            options: [.calculationModeCubic, .repeat],
            animations: {
                UIView.addKeyframe(
                    withRelativeStartTime: 0,
                    relativeDuration: 0.5,
                    animations: {
                        self.loadingCatImageView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                        self.loadingGlassesImageView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                })
                UIView.addKeyframe(
                    withRelativeStartTime: 0.5,
                    relativeDuration: 0.5,
                    animations: {
                        self.loadingCatImageView.transform = CGAffineTransform.identity
                        self.loadingGlassesImageView.transform = CGAffineTransform.identity
                })
        })
    }
    
    // Stop loading animation
    func doneLoading() {
        loadingCatImageView.layer.removeAllAnimations()
        loadingGlassesImageView.layer.removeAllAnimations()
    }
    
    // Set videos for players
    func setPlayers(previous: AVPlayer?, current: AVPlayer, next: AVPlayer?) {
        topCatPlayerLayer.player?.pause()
        previousPlayer = previous
        topCatPlayerLayer.player = current
        nextPlayer = next
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
                NotificationCenter.default.removeObserver(self.topCatPlayerLayer.player!.currentItem!)
                self.inputDelegate.nextCat()
            }
        }
        topCatPlayerLayer.player!.seek(to: kCMTimeZero)
        topCatPlayerLayer.player!.play()
    }
    
    func removePlayers() {
        guard topCatPlayerLayer.player?.currentItem != nil else { return }
        NotificationCenter.default.removeObserver(self.topCatPlayerLayer.player!.currentItem!)
        previousPlayer = nil
        topCatPlayerLayer.player?.pause()
        topCatPlayerLayer.player = nil
        nextPlayer = nil
    }
    
    func pauseTopPlayer() {
        guard topCatPlayerLayer.player?.currentItem != nil else { return }
        NotificationCenter.default.removeObserver(self.topCatPlayerLayer.player!.currentItem!)
        topCatPlayerLayer.player!.pause()
    }
    
    func startTopPlayer() {
        guard topCatPlayerLayer.player?.currentItem != nil else { return }
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
                NotificationCenter.default.removeObserver(self.topCatPlayerLayer.player!.currentItem!)
                self.inputDelegate.nextCat()
            }
        }
        topCatPlayerLayer.player!.seek(to: kCMTimeZero)
        topCatPlayerLayer.player!.play()
    }
    
    // Initial configuration
    func configure() {
        
        // Setup
        screenTapGestureRecognizer.addTarget(self, action: #selector(screenTapped))
        
        // Gesture recognition
        addGestureRecognizer(screenTapGestureRecognizer)
        
        // Add views and layers
        addSubview(loadingCatImageView)
        addSubview(loadingGlassesImageView)
        layer.addSublayer(topCatPlayerLayer)
        
        // Constrain
        loadingCatImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            loadingCatImageViewWidth = $0.width.equalTo(0).constraint
            $0.height.equalTo(loadingCatImageView.snp.width).dividedBy(#imageLiteral(resourceName: "LoadingCat").size.width / #imageLiteral(resourceName: "LoadingCat").size.height)
        }
        loadingGlassesImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            loadingGlassesImageViewWidth = $0.width.equalTo(0).constraint
            $0.height.equalTo(loadingGlassesImageView.snp.width).dividedBy(#imageLiteral(resourceName: "LoadingGlasses").size.width / #imageLiteral(resourceName: "LoadingGlasses").size.height)
        }
    }
}
