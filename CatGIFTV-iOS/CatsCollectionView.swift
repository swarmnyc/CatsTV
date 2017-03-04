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
    let reuseIdentifier = "CatCollectionViewCell"
    
    // Initialization
    init() {
        super.init(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        configure()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Detect touches to determine user activity status
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        inputDelegate.userDidInteract()
        return super.hitTest(point, with: event)
    }
    
    // Update data source with new cats
    func update(with cats: [Cat], at startIndex: Int) {
        var indexPaths = [IndexPath]()
        for i in 0..<cats.count {
            indexPaths.append(IndexPath(item: startIndex + i, section: 0))
            print(i)
        }
        insertItems(at: indexPaths)
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
    
    func layoutCellsForPortraitOrientation() {
        (collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        layoutIfNeeded()
    }
    
    func layoutCellsForLandscapeOrientation() {
        (collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSize(width: UIScreen.main.bounds.height, height: UIScreen.main.bounds.width)
        layoutIfNeeded()
    }
    
    // Initial configuration
    func configure() {
        
        // Setup
        alpha = 0
        backgroundColor = UIColor.clear
        isPagingEnabled = true
        showsHorizontalScrollIndicator = false
        decelerationRate = UIScrollViewDecelerationRateFast
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.scrollDirection = .horizontal
        
        // Registration
        register(CatCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        delegate = self
        dataSource = self
    }
}

// Cats collection view delegate
extension CatsCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        (collectionView.cellForItem(at: indexPath) as! CatCollectionViewCell).startPlayer()
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! CatCollectionViewCell
        cell.pausePlayer()
        cell.hideVideo()
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
        cell.setVideo()
        return cell
    }
}
