


import UIKit
import AVFoundation

class CatsCollectionView: UICollectionView {
    // Delegation
    weak var inputDelegate: CatInputProtocol!
    // Properties
    var previousPlayer: AVPlayer?
    var nextPlayer: AVPlayer?
    
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
        }
        insertItems(at: indexPaths)
    }
    func setCurrentPlayer() {
        if let visibleCell = visibleCells.first as? CatCollectionViewCell {
            visibleCell.setPlayer()
        }
    }
    func removeCurrentPlayer() {
        if let visibleCell = visibleCells.first as? CatCollectionViewCell {
            visibleCell.pausePlayer()
            visibleCell.hideVideo()
        }
    }
    func pausePreviousPlayer(_ index: Int) {
        let cell = collectionView(self, cellForItemAt: IndexPath(item: index, section: 0)) as! CatCollectionViewCell
        cell.pausePlayer()
        cell.rewindPlayer()
    }
    func resizeCellsForOrientationChange() {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        layout.invalidateLayout()
        for cell in visibleCells as! [CatCollectionViewCell] {
            cell.catPlayerLayer.frame = CGRect(x: 3, y: 3, width: UIScreen.main.bounds.width - 6, height: UIScreen.main.bounds.height - 6)
            layoutIfNeeded()
        }
    }
    // Initial configuration
    func configure() {
        // Setup
        alpha = 0
        backgroundColor = UIColor.clear
        isPagingEnabled = true
        showsHorizontalScrollIndicator = false
        decelerationRate = UIScrollViewDecelerationRateFast
        // Layout
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        // Registration
        register(CatCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        delegate = self
        dataSource = self
    }
}

// Cats collection view delegate
extension CatsCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! CatCollectionViewCell
        if cell.catPlayerLayer.frame != CGRect(x: 3, y: 3, width: UIScreen.main.bounds.width - 6, height: UIScreen.main.bounds.height - 6) {
            cell.catPlayerLayer.frame = CGRect(x: 3, y: 3, width: UIScreen.main.bounds.width - 6, height: UIScreen.main.bounds.height - 6)
            layoutIfNeeded()
        }
        cell.setPlayer()
        cell.rewindPlayer()
        cell.startPlayer()
        inputDelegate.currentCatIndex(indexPath.item)
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! CatCollectionViewCell
        cell.pausePlayer()
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CatCollectionViewCell
        cell.rewindPlayer()
        cell.startPlayer()
        UIView.animate(
            withDuration: 0.15,
            delay: 0,
            options: [.curveEaseIn, .allowUserInteraction],
            animations: {
                cell.whiteView.alpha = 0.2
        })
        UIView.animate(
            withDuration: 0.15,
            delay: 0.05,
            options: [.curveEaseOut, .allowUserInteraction],
            animations: {
                cell.whiteView.alpha = 0
        })
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
