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
}

protocol CatInputProtocol {
  func catTapped(_: AVPlayer, _ index: Int)
}

protocol CatOutputProtocol {
  func nextCat()
}

class CatsViewController: UIViewController {
  
  // Presenter
  var presenter: CatsPresenterProtocol!
  
  // Subviews
  var rootView: CatsView {
    return view as! CatsView
  }
  
  // Properties
  var isLaunch = true
  
  // Life cycle
  override func loadView() {
    view = CatsView()
    rootView.addDelegates(self, self)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configure()
    presenter.provideCats()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    rootView.makeAdjustmentsAfterInitialLayout()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if isLaunch {
      rootView.animateFromLaunch()
      isLaunch = false
    }
  }
}

// Cats view protocol
extension CatsViewController: CatsViewProtocol {
  func store(cats: [Cat]) {
    print("🐈 got \(cats.count) cat urls from reddit 🐈")
    if rootView.catsCollectionView.isLoading {
      rootView.topCatVideoView.setVideo(AVPlayer(url: cats[0].url))
      rootView.topCatVideoView.nextPlayer = AVPlayer(url: cats[1].url)
      rootView.catsCollectionView.isLoading = false
    }
    rootView.catsCollectionView.cats.append(contentsOf: cats)
    rootView.catsCollectionView.reloadData()
  }
}

extension CatsViewController: CatInputProtocol {
  func catTapped(_ player: AVPlayer, _ index: Int) {
    rootView.topCatVideoView.setVideo(player)
    rootView.topCatVideoView.index = index
  }
}

extension CatsViewController: CatOutputProtocol {
  func nextCat() {
    rootView.topCatVideoView.index += 1
    rootView.topCatVideoView.setVideo(rootView.topCatVideoView.nextPlayer!)
    rootView.topCatVideoView.nextPlayer = AVPlayer(url: rootView.catsCollectionView.cats[rootView.topCatVideoView.index].url)
    rootView.catsCollectionView.scrollToItem(at: IndexPath(item: rootView.topCatVideoView.index, section: 0), at: .left, animated: true)
  }
}

// Configuration
private extension CatsViewController {
  func configure() {
    rootView.addTargets()
  }
}
