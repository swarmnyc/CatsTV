//
//  CatsView.swift
//  CatsTV
//
//  Created by William Robinson on 3/2/17.
//
//
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
    
    // Delegation
    weak var inputDelegate: CatInputProtocol!
    
    // View and layers
    lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "Background"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    lazy var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    lazy var tvCatView: TVCatView = TVCatView()
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "CatGIFTV"
        label.font = UIFont.systemFont(ofSize: 28, weight: UIFontWeightBlack)
        label.textColor = UIColor.white
        return label
    }()
    lazy var topCatVideoView = TopCatVideoView()
    lazy var catsCollectionView = CatsCollectionView()
    
    // Gesture recognition
    lazy var rightSwipeGestureReconizer: UISwipeGestureRecognizer = {
        let recognizer = UISwipeGestureRecognizer()
        recognizer.direction = .right
        return recognizer
    }()
    lazy var leftSwipeGestureReconizer: UISwipeGestureRecognizer = {
        let recognizer = UISwipeGestureRecognizer()
        recognizer.direction = .left
        return recognizer
    }()
    
    // Constraints
    var topCatVideoViewWidth: Constraint!
    var topCatVideoViewHeight: Constraint!
    
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
    
    func swipedRight() {
        NotificationCenter.default.removeObserver(topCatVideoView.topCatPlayerLayer.player!.currentItem!)
        inputDelegate.nextCat()
    }
    func swipedLeft() {
        NotificationCenter.default.removeObserver(topCatVideoView.topCatPlayerLayer.player!.currentItem!)
        inputDelegate.previousCat()
    }
    
    // Delegation setup
    func addDelegates(_ inputDelegate: CatInputProtocol) {
        self.inputDelegate = inputDelegate
        topCatVideoView.inputDelegate = inputDelegate
        catsCollectionView.inputDelegate = inputDelegate
    }
    
    // Adjustments after frames have been defined by Auto Layout constraints
    func makeAdjustmentsAfterInitialLayout() {
        guard !inputDelegate.didPerformInitialLayout else { return }
        topCatVideoView.topCatPlayerLayer.frame = topCatVideoView.bounds
        topCatVideoView.fullScreenFrame =
            CGRect(x: -topCatVideoView.frame.minX,
                   y: -topCatVideoView.frame.minY,
                   width: UIScreen.main.bounds.width,
                   height: UIScreen.main.bounds.height)
        CALayer.shadow(topCatVideoView)
        inputDelegate.didPerformInitialLayout = true
    }
    
    // Resize top cat video to fill screen
    func makeFullScreen() {
        blurView.isHidden = false
        topCatVideoView.isUserInteractionEnabled = false
        catsCollectionView.isUserInteractionEnabled = false
        UIView.animateKeyframes(
            withDuration: 0.8,
            delay: 0,
            options: [],
            animations: {
                UIView.addKeyframe(
                    withRelativeStartTime: 0,
                    relativeDuration: 0.2,
                    animations: {
                        self.topCatVideoView.transform = CGAffineTransform.identity
                })
                UIView.addKeyframe(
                    withRelativeStartTime: 0,
                    relativeDuration: 0.6,
                    animations: {
                        self.topCatVideoView.layer.shadowColor = UIColor.black.cgColor
                        self.blurView.effect = UIBlurEffect(style: .dark)
                        self.layoutIfNeeded()
                })
                UIView.addKeyframe(
                    withRelativeStartTime: 0.2,
                    relativeDuration: 0.8,
                    animations: {
                        self.topCatVideoView.topCatPlayerLayer.frame = self.topCatVideoView.fullScreenFrame
                        self.layoutIfNeeded()
                })
        })
    }
    
    // Set top cat video to original size
    func makeRegularScreen() {
        UIView.animateKeyframes(
            withDuration: 0.7,
            delay: 0,
            options: [],
            animations: {
                UIView.addKeyframe(
                    withRelativeStartTime: 0,
                    relativeDuration: 0.8,
                    animations: {
                        self.topCatVideoView.topCatPlayerLayer.frame = self.topCatVideoView.bounds
                        self.blurView.effect = nil
                        self.layoutIfNeeded()
                })
        }) { _ in
            self.blurView.isHidden = true
            let item = self.topCatVideoView.index + (self.topCatVideoView.index + 1 < self.inputDelegate.catsCount ? 1 : 0)
            self.catsCollectionView.scrollToItem(at: IndexPath(item: item, section: 0), at: .left, animated: true)
            self.topCatVideoView.isUserInteractionEnabled = true
            self.catsCollectionView.isUserInteractionEnabled = true
        }
    }
    
    // Set gesture recognition for regular and full screen modes
    func toggleGestureRecognizersForScreenStatus() {
        if inputDelegate.isFullScreen {
            topCatVideoView.removeGestureRecognizer(topCatVideoView.screenTapGestureRecognizer)
            addGestureRecognizer(leftSwipeGestureReconizer)
            addGestureRecognizer(rightSwipeGestureReconizer)
        } else {
            topCatVideoView.addGestureRecognizer(topCatVideoView.screenTapGestureRecognizer)
            removeGestureRecognizer(leftSwipeGestureReconizer)
            removeGestureRecognizer(rightSwipeGestureReconizer)
        }
    }
    
    // Initial configuration
    func configure() {
        
        // Setup
        isUserInteractionEnabled = false
        
        // Add targets
        rightSwipeGestureReconizer.addTarget(self, action: #selector(swipedRight))
        leftSwipeGestureReconizer.addTarget(self, action: #selector(swipedLeft))
        
        // Add subviews and sublayers
        addSubview(backgroundImageView)
        addSubview(topCatVideoView)
        addSubview(blurView)
        addSubview(tvCatView)
        addSubview(catsCollectionView)
        addSubview(titleLabel)
        
        // Add constraints
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        topCatVideoView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.centerX.equalToSuperview()
            topCatVideoViewWidth = $0.width.equalToSuperview().dividedBy(1.1).constraint
            topCatVideoViewHeight = $0.height.equalToSuperview().dividedBy(1.8).constraint
        }
        blurView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        tvCatView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(80)
            $0.height.equalTo(101)
        }
        catsCollectionView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(25)
            $0.left.equalToSuperview().offset(10)
            $0.bottom.equalToSuperview().offset(-10)
            $0.right.equalToSuperview()
        }
        titleLabel.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-30)
            $0.top.equalToSuperview().offset(45)
        }
    }
}

