//
//  CatsCollectionView.swift
//  CatsTV
//
//  Created by William Robinson on 3/2/17.
//
//

import UIKit
import AVFoundation

class CatsCollectionView: UICollectionView {
    
    // Delegation
    weak var inputDelegate: CatInputProtocol!
    
    // Constants
    let loadingIdentifier = "LoadingCollectionViewCell"
    let reuseIdentifier = "CatCollectionViewCell"
    let itemSize = CGSize(width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height - 35)
    let spacing: CGFloat = 10
    
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
    
    // Update data source with new cats
    func update(with cats: [Cat]) {
        let startIndex = self.inputDelegate.catsCount
        self.inputDelegate.append(cats: cats)
        
        guard startIndex > 0 else { return }
        var indexPaths = [IndexPath]()
        for i in 0..<cats.count {
            indexPaths.append(IndexPath(item: startIndex + i, section: 0))
        }
        insertItems(at: indexPaths)
        
        guard let visibleCells = visibleCells as? [CatCollectionViewCell] else { return }
        for cell in visibleCells {
            cell.hideLoadingMessage()
        }
    }
    
    func startPlayers() {
        guard let visibleCells = visibleCells as? [CatCollectionViewCell] else { return }
        for cell in visibleCells {
            cell.setVideo()
        }
    }
    
    func pausePlayers() {
        guard let visibleCells = visibleCells as? [CatCollectionViewCell] else { return }
        for cell in visibleCells {
            cell.pausePlayer()
        }
    }
    
    // Initial configuration
    func configure() {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = itemSize
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = spacing
        layout.scrollDirection = .horizontal
        layer.cornerRadius = 20
        clipsToBounds = true
        backgroundColor = UIColor.clear
        isPagingEnabled = true
        showsHorizontalScrollIndicator = false
        decelerationRate = UIScrollViewDecelerationRateFast
        delegate = self
        dataSource = self
        register(CatCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
}

// Cats collection view delegate
extension CatsCollectionView: UICollectionViewDelegate {
    
    // Selection
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CatCollectionViewCell
        cell.setVideo()
    }
    
    // Scrolling
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        inputDelegate.setScrolling()
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        for cell in visibleCells as! [CatCollectionViewCell] {
            cell.setThumbnail()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        inputDelegate.setStoppedScrolling()
    }
}

// Cats collection view data source
extension CatsCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return inputDelegate.catsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CatCollectionViewCell
        cell.cat = inputDelegate.cat(index: indexPath.item)
        cell.setThumbnail()
        return cell
    }
}
