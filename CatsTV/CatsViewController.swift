//
//  CatsViewController.swift
//  CatsTV
//
//  Created by William Robinson on 2/14/17.
//
//

import UIKit
import SnapKit
import AVKit

// Defines commands sent from presenter to view
protocol CatsViewProtocol: class {
  func store(cats: [Cat])
  func showCats()
}

class CatsViewController: UIViewController {
  
  // Presenter
  var presenter: CatsPresenterProtocol!
  
  // Properties
  var isLaunch = true
  
  // Subviews
  var rootView: CatsView {
    get {
      return view as! CatsView
    }
    set {
      view = newValue
    }
  }
  
  // Properties
  
  
  // Life cycle
  override func loadView() {
    rootView = CatsView()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configure()
    presenter.provideCats()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    // TODO what does this do?
    rootView.makeAdjustmentsAfterInitialLayout()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if isLaunch {
      rootView.animateFromLaunch()
      isLaunch = false
    }
  }
  
  // Focus
  override var preferredFocusEnvironments: [UIFocusEnvironment] {
    return [rootView]
  }
  
  // Presses
  override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
    if presses.first?.type == UIPressType.menu, rootView.isFullScreen {
      rootView.toggleFullScreen()
    } else {
      super.pressesBegan(presses, with: event)
    }
  }
}

// Cats view protocol
extension CatsViewController: CatsViewProtocol {
  func store(cats: [Cat]) {
    print("🐈 got \(cats.count) cat urls from reddit 🐈")
    self.rootView.catsCollectionView.cats = cats
  }
  
  // TODO: Loop video twice then continue
  func showCats() {
    rootView.showCats()
  }
}

// Cats collection view delegate
extension CatsViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let cellPlayerItem = (collectionView.cellForItem(at: indexPath) as! CatCollectionViewCell).catPlayerLayer.player!.currentItem else { return }
    let topCatPlayer = rootView.topCatVideoView.topCatPlayerLayer.player!
    topCatPlayer.replaceCurrentItem(with: cellPlayerItem.copy() as? AVPlayerItem)
  }
  
  func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
    //    var nextIndexPath: IndexPath?
    //    var prevIndexPath: IndexPath?
    print("did update focus")
    
    if let indexPath = context.nextFocusedIndexPath,
      let cell = collectionView.cellForItem(at: indexPath) as? CatCollectionViewCell,
      cell.isFocused {
      //      nextIndexPath = indexPath
      coordinator.addCoordinatedAnimations ({
        cell.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        cell.layer.shadowOpacity = 1
      }) {
        if cell.catPlayerLayer.player!.status == .readyToPlay {
          cell.catPlayerLayer.player!.play()
        }
      }
    }
    
    if let indexPath = context.previouslyFocusedIndexPath,
      let cell = collectionView.cellForItem(at: indexPath) as? CatCollectionViewCell {
      //      prevIndexPath = indexPath
      if cell.catPlayerLayer.player!.status == .readyToPlay {
        cell.catPlayerLayer.player!.pause()
        cell.catPlayerLayer.player!.seek(to: kCMTimeZero)
      }
      coordinator.addCoordinatedAnimations ({
        cell.transform = CGAffineTransform.identity
        cell.layer.shadowOpacity = 0.7
      })
    }
    
    //    if let nextIndexPath = nextIndexPath {
    //      for (index, visibleIndexPath) in collectionView.indexPathsForVisibleItems.enumerated() {
    //        guard nextIndexPath == visibleIndexPath else { continue }
    //        if let prevIndexPath = prevIndexPath {
    //          if prevIndexPath.item < nextIndexPath.item {
    //            // TODO: Cell gradient changes
    //          } else if prevIndexPath.item > nextIndexPath.item {
    //            // TODO: Cell gradient changes
    //          }
    //        }
    //      }
    //    }
  }
}

// Cats collection view data source
extension CatsViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return rootView.catsCollectionView.cats.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: rootView.catsCollectionView.reuseIdentifier, for: indexPath) as! CatCollectionViewCell
    collectionView.updateFocusIfNeeded()
    if rootView.isScrolling {
      rootView.updateFocusIfNeeded()
    } else {
      cell.setVideo(with: rootView.catsCollectionView.cats[indexPath.item])
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    rootView.updateFocusIfNeeded()
  }
  
  func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    (cell as! CatCollectionViewCell).catPlayerLayer.player!.cancelPendingPrerolls()
  }
  
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    rootView.isScrolling = true
  }
  
  func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
    rootView.updateFocusIfNeeded()
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    rootView.isScrolling = false
    rootView.catsCollectionView.loadCats()
    rootView.updateFocusIfNeeded()
  }
}

// Configuration
private extension CatsViewController {
  func configure() {
    rootView.catsCollectionView.delegate = self
    rootView.catsCollectionView.dataSource = self
    rootView.addTargets()
  }
}
