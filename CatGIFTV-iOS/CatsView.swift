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
    
    // Subviews and sublayers
    lazy var catsCollectionView = CatsCollectionView()
    lazy var titleImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "Title"))
        imageView.contentMode = .scaleAspectFit
        imageView.layer.shadowOffset = CGSize(width: 3, height: 5)
        imageView.layer.shadowRadius = 7
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOpacity = 0
        return imageView
    }()
    
    // Initialization
    init() {
        super.init(frame: CGRect.zero)
        configure()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Delegation setup
    func addDelegates(_ inputDelegate: CatInputProtocol) {
        self.inputDelegate = inputDelegate
        catsCollectionView.inputDelegate = inputDelegate
    }
    
    // Animations for application launch
    func animateAppLaunch() {
        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.titleImageView.snp.remakeConstraints {
                    $0.top.equalToSuperview()
                    $0.right.equalToSuperview().offset(-20)
                    $0.width.equalTo(110)
                }
                self.titleImageView.layer.shadowOpacity = 0.6
                self.catsCollectionView.alpha = 1
                self.layoutIfNeeded()
        }) { _ in
            self.inputDelegate.userDidInteract()
        }
    }
    
    // Animations when user becomes active after previously being inactive
    func animateToActiveInterface() {
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseIn,
            animations: {
                self.titleImageView.snp.updateConstraints {
                    $0.width.equalTo(110)
                }
                self.titleImageView.alpha = 1
                self.layoutIfNeeded()
        })
    }
    
    // Animations when user becomes inactive
    func animateToInactiveInterface() {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                self.titleImageView.snp.updateConstraints {
                    $0.width.equalTo(80)
                }
                self.titleImageView.alpha = 0.6
                self.layoutIfNeeded()
        })
    }
    
    // Initial configuration
    func configure() {
        
        // Add subviews and sublayers
        addSubview(catsCollectionView)
        addSubview(titleImageView)
        
        // Add constraints
        catsCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        titleImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}

