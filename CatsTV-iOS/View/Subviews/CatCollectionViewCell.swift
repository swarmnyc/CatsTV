




import UIKit
import SnapKit
import AVFoundation

class CatCollectionViewCell: UICollectionViewCell {
    
    // Views and layers
    lazy var catThumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 6
        imageView.clipsToBounds = true
        return imageView
    }()
    lazy var catPlayerLayer: AVPlayerLayer = {
        let playerLayer = AVPlayerLayer()
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerLayer.needsDisplayOnBoundsChange = true
        playerLayer.cornerRadius = 6
        playerLayer.masksToBounds = true
        return playerLayer
    }()
    lazy var whiteView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.alpha = 0
        return view
    }()
    
    // Gesture recognition
    let longPressGestureRecognizer = UILongPressGestureRecognizer()
    
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
    
    // Reset cell
    override func prepareForReuse() {
        hideVideo()
        super.prepareForReuse()
    }
    
    // Set thumbnail image
    func setThumbnail() {
        catThumbnailImageView.image = cat.image
    }
    // Set video player
    func setPlayer() {
        guard catPlayerLayer.player == nil else { return }
        let player = AVPlayer(url: cat.url)
        player.isMuted = true
        catPlayerLayer.player = player
        NotificationCenter.default.addObserver(
            forName: Notification.Name.AVPlayerItemDidPlayToEndTime,
            object: catPlayerLayer.player!.currentItem,
            queue: OperationQueue.main
        ) { _ in
            self.catPlayerLayer.player?.seek(to: kCMTimeZero)
            self.catPlayerLayer.player?.play()
        }
    }
    // Start video playback
    func startPlayer() {
        catPlayerLayer.player?.play()
    }
    // Stop video playback
    func pausePlayer() {
        catPlayerLayer.player?.pause()
    }
    // Set player to original starting point
    func rewindPlayer() {
        catPlayerLayer.player?.seek(to: kCMTimeZero)
    }
    
    // Brief white flash on screen when touched
    func whiteFlash() {
        UIView.animate(
            withDuration: 0.07,
            delay: 0,
            options: [.curveEaseIn, .allowUserInteraction],
            animations: {
                self.whiteView.alpha = 0.2
        })
        UIView.animate(
            withDuration: 0.13,
            delay: 0.07,
            options: [.curveEaseOut, .allowUserInteraction],
            animations: {
                self.whiteView.alpha = 0
        })
    }
    
    func hideVideo() {
        guard catPlayerLayer.player != nil else { return }
        NotificationCenter.default.removeObserver(catPlayerLayer.player!.currentItem!)
        catPlayerLayer.player = nil
    }
    
    func longPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            catPlayerLayer.player?.rate = 0.35
        case .ended:
            catPlayerLayer.player?.rate = 1
        default:
            return
        }
    }
}

private extension CatCollectionViewCell {
    // Initial configuration
    func configure() {
        // Setup
        catPlayerLayer.frame = CGRect(x: 3, y: 3, width: UIScreen.main.bounds.width - 6, height: UIScreen.main.bounds.height - 6)
        // Gesture recognition
        longPressGestureRecognizer.addTarget(self, action: #selector(longPress))
        addGestureRecognizer(longPressGestureRecognizer)
        // Add subviews and sublayers
        contentView.addSubview(catThumbnailImageView)
        contentView.layer.addSublayer(catPlayerLayer)
        contentView.addSubview(whiteView)
        // Constrain
        catThumbnailImageView.snp.makeConstraints {
            $0.edges.equalTo(UIEdgeInsetsMake(3, 3, 3, 3))
        }
        whiteView.snp.makeConstraints {
            $0.edges.equalTo(UIEdgeInsetsMake(3, 3, 3, 3))
        }
    }
}




