




import UIKit
import AVFoundation

class CatsCollectionView: UICollectionView {
    
    // Delegation
    weak var inputDelegate: CatInputProtocol!
    
    // Properties
    var previousPlayer: AVPlayer?
    var nextPlayer: AVPlayer?
    var currentFrame: CGRect?
    var visibleRect: CGRect {
        return CGRect(x: 3, y: 3, width: UIScreen.main.bounds.width - 6, height: UIScreen.main.bounds.height - 6)
    }
    
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
    
    // Set video for current player and begin playback
    func setCurrentPlayer() {
        if let cell = visibleCells.first as? CatCollectionViewCell {
            cell.setPlayer()
            cell.startPlayer()
        }
    }
    
    // Pause playback and remove video for current player
    func removeCurrentPlayer() {
        if let cell = visibleCells.first as? CatCollectionViewCell {
            cell.pausePlayer()
            cell.hideVideo()
        }
    }
    
    // Cell resizing for change in device orientation
    func resizeCellsForOrientationChange() {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        layout.invalidateLayout()
        guard !visibleCells.isEmpty else { return }
        for cell in visibleCells as! [CatCollectionViewCell] {
            guard cell.catPlayerLayer.frame != visibleRect else { return }
            cell.catPlayerLayer.frame = visibleRect
            layoutIfNeeded()
        }
        scrollToItem(at: IndexPath(item: inputDelegate.catIndex, section: 0), at: .left, animated: false)
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
    
    // Cell will appear on screen
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! CatCollectionViewCell
        if cell.catPlayerLayer.frame != visibleRect {
            cell.catPlayerLayer.frame = visibleRect
            layoutIfNeeded()
        }
        cell.setPlayer()
        cell.startPlayer()
    }
    
    // Cell on screen was selected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CatCollectionViewCell
        cell.rewindPlayer()
        cell.startPlayer()
        cell.whiteFlash()
    }
    
    // Cell will disappear offscreen
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! CatCollectionViewCell
        cell.pausePlayer()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentCatIndex = Int(round(CGFloat(inputDelegate.catsCount) * (scrollView.contentOffset.x / scrollView.contentSize.width)))
        inputDelegate.currentCatIndex(currentCatIndex)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        inputDelegate.finishedScrolling()
    }
}

// Cats collection view data source
extension CatsCollectionView: UICollectionViewDataSource {
    
    // Number of cats available for display
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return inputDelegate.catsCount
    }
    
    // Cell setup using cat at corresponding index
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CatCollectionViewCell
        cell.cat = inputDelegate.cat(index: indexPath.item)
        cell.setThumbnail()
        return cell
    }
}




