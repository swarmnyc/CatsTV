//
//  CatsCollectionView.swift
//  CatsTV
//
//  Created by William Robinson on 2/14/17.
//
//

import UIKit
import AVFoundation

class CatsCollectionView: UICollectionView {
  
  // Delegation
  var catTapDelegate: CatInputProtocol!
  
  // Properties
  lazy var cats: [Cat] = []
  var isLoading = true
  var isScrolling = false
  
  // Constants
  let loadingIdentifier = "LoadingCollectionViewCell"
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
  
  // Initial configuration
  func configure() {
    let layout = collectionViewLayout as! UICollectionViewFlowLayout
    layout.itemSize = itemSize
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = spacing
    layout.scrollDirection = .horizontal
    clipsToBounds = false
    decelerationRate = UIScrollViewDecelerationRateFast
    delegate = self
    dataSource = self
    register(LoadingCollectionViewCell.self, forCellWithReuseIdentifier: loadingIdentifier)
    register(CatCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
  }
}

// Cats collection view delegate
extension CatsCollectionView: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if (collectionView.cellForItem(at: indexPath) as! CatCollectionViewCell).catPlayerLayer.player != nil {
      catTapDelegate.catTapped(AVPlayer(url: cats[indexPath.item].url), indexPath.item)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
    DispatchQueue.main.async {
      guard let visibleCells = self.visibleCells as? [CatCollectionViewCell] else { return }
      for cell in visibleCells {
        if cell.isFocused {
          cell.catPlayerLayer.player = AVPlayer(url: cell.cat.url)
          cell.catPlayerLayer.player!.play()
          cell.catPlayerLayer.isHidden = false
        } else {
          cell.catPlayerLayer.player?.seek(to: kCMTimeZero)
          cell.catPlayerLayer.player?.pause()
          cell.catPlayerLayer.isHidden = true
        }
      }
    }
  }
}

// Cats collection view data source
extension CatsCollectionView: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return !isLoading ? cats.count : 6
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard !isLoading else {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: loadingIdentifier, for: indexPath) as! LoadingCollectionViewCell
      cell.setLoading()
      return cell
    }
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CatCollectionViewCell
    cell.cat = (collectionView as! CatsCollectionView).cats[indexPath.item]
    cell.setThumbnail()
    return cell
  }
  
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    isScrolling = true
  }
  
  func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
    for cell in visibleCells as! [CatCollectionViewCell] {
      cell.setThumbnail()
    }
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    isScrolling = false
    if indexPathsForVisibleItems.last!.item < cats.count - 1 {
      reloadData()
    }
  }
}


