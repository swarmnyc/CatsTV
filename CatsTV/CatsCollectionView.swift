//
//  CatsCollectionView.swift
//  CatsTV
//
//  Created by William Robinson on 2/14/17.
//
//

import UIKit


protocol CatsCollectionViewDelegate {
  func catTapped(cat: Cat)
}

class CatsCollectionView: UICollectionView {
  
  // Properties
  lazy var cats: [Cat] = []
  
  // Constants
  let reuseIdentifier = "CatCollectionViewCell"
  let itemSize = CGSize(width: 230, height: 150)
  let spacing: CGFloat = 100
  
  // Initialization
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
    super.init(frame: frame, collectionViewLayout: layout)
  }
  
  convenience init() {
    self.init(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    configure()
  }
  
  func didBeginScrolling() {
    
  }
  
  func loadCats() {
    var catlessCells: [CatCollectionViewCell : Int] = [:]
    for (index, cell) in (visibleCells as! [CatCollectionViewCell]).enumerated() {
      if cell.isFocused {
        UIView.animate(withDuration: 0.2, animations: {
          cell.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
          cell.layer.shadowOpacity = 1
        }) { _ in
          if cell.catPlayerLayer.player!.status == .readyToPlay {
            cell.catPlayerLayer.player!.play()
          }
        }
      }
      if cell.catPlayerLayer.player!.currentItem == nil {
        catlessCells[cell] = indexPathsForVisibleItems[index].item
      }
    }
    
    for (catlessCell, catIndex) in catlessCells {
      catlessCell.setVideo(with: cats[catIndex])
    }
  }
  
  // Initial configuration
  func configure() {
    let layout = collectionViewLayout as! UICollectionViewFlowLayout
    layout.itemSize = itemSize
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = spacing
    layout.scrollDirection = .horizontal
    clipsToBounds = false
    decelerationRate = UIScrollViewDecelerationRateFast
    register(CatCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
  }
}
