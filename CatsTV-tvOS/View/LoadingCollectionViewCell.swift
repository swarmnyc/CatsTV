//
//  LoadingCollectionViewCell.swift
//  CatsTV
//
//  Created by William Robinson on 2/26/17.
//
//

import UIKit
import SnapKit

class LoadingCollectionViewCell: UICollectionViewCell {
  
  // Views
  lazy var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
  lazy var loadingCatImageView = UIImageView(image: #imageLiteral(resourceName: "LoadingCat"))
  lazy var loadingGlassesImageView = UIImageView(image: #imageLiteral(resourceName: "LoadingGlasses"))
  
  // Initialization
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    loadingCatImageView.layer.removeAllAnimations()
    loadingGlassesImageView.layer.removeAllAnimations()
  }
  
  // Loading new video
  func setLoading() {
    UIView.animate(
      withDuration: 0.4,
      delay: 0,
      options: [.curveEaseIn, .repeat, .autoreverse, .beginFromCurrentState],
      animations: {
        self.blurView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        self.loadingCatImageView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        self.loadingGlassesImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
    })
  }
  
  // Initial configuration
  func configure() {
    
    // Add subviews
    contentView.addSubview(blurView)
    contentView.addSubview(loadingCatImageView)
    contentView.addSubview(loadingGlassesImageView)
    
    
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
  }
}
