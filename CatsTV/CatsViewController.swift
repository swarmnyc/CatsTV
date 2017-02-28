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
protocol CatsOutputProtocol: class {
  func store(cats: [Cat])
}

// Defines inputs in view
protocol CatInputProtocol: class {
  var catsCount: Int { get }
  var currentVideoIndex: Int { get }
  var isFullScreen: Bool { get set }
  var isScrolling: Bool { get }
  var isInitialLaunch: Bool { get }
  func append(cats: [Cat])
  func cat(index: Int) -> Cat
  func playerForCat(index: Int) -> AVPlayer
  func toggleFullScreen()
  func setScrolling()
  func setStoppedScrolling()
  func userDidInteract()
  func catTapped(previous: AVPlayer?, current: AVPlayer, next: AVPlayer?, currentIndex: Int)
  func nextCat()
  func previousCat()
}

class CatsViewController: UIViewController {
  
  // Presenter
  var presenter: CatsPresenterProtocol!
  
  // Subviews
  var rootView: CatsView {
    return view as! CatsView
  }
  
  // Properties
  lazy var cats: [Cat] = []
  var idleTimer: Timer?
  
  // Status flags
  var isInitialLaunch = true
  var isFullScreen = false
  var isScrolling = false
  
  // Life cycle
  override func loadView() {
    view = CatsView()
    rootView.addDelegates(self)
    rootView.isUserInteractionEnabled = false
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    presenter.provideCats()
    configure()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    rootView.makeAdjustmentsAfterInitialLayout()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if isInitialLaunch {
      rootView.animateFromLaunch()
    }
  }
}

// Cats view protocol
extension CatsViewController: CatsOutputProtocol {
  func store(cats: [Cat]) {
    print("🐈 got \(cats.count) cat urls from reddit 🐈")
    rootView.catsCollectionView.update(with: cats)
    if isInitialLaunch {
      isInitialLaunch = false
      setupVideoPlayersFromLaunch()
      userDidInteract()
    }
  }
  
  private func setupVideoPlayersFromLaunch() {
    guard cats.count > 1 else { return }
    let current = AVPlayer(url: cats[0].url)
    let next = AVPlayer(url: cats[1].url)
    current.isMuted = true
    next.isMuted = true
    rootView.topCatVideoView.setPlayers(previous: nil, current: current, next: next)
    rootView.catsCollectionView.reloadData()
    rootView.isUserInteractionEnabled = true
  }
}

extension CatsViewController: CatInputProtocol {
  var catsCount: Int {
    return cats.count
  }
  
  var currentVideoIndex: Int {
    return rootView.topCatVideoView.index
  }
  
  func append(cats: [Cat]) {
    self.cats.append(contentsOf: cats)
  }
  
  func cat(index: Int) -> Cat {
    return cats[index]
  }
  
  func playerForCat(index: Int) -> AVPlayer {
    return AVPlayer(url: cats[index].url)
  }
  
  func toggleFullScreen() {
    isFullScreen ? rootView.makeRegularScreen() : rootView.makeFullScreen()
    isFullScreen = !isFullScreen
    rootView.topCatVideoView.toggleGestureRecognizersForScreenStatus()
  }
  
  func setScrolling() {
    isScrolling = true
  }
  
  func setStoppedScrolling() {
    isScrolling = false
  }
  
  func userDidInteract() {
    idleTimer?.invalidate()
    idleTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: false) { _ in
      guard !self.isFullScreen else { return }
      self.toggleFullScreen()
    }
  }
  
  func catTapped(previous: AVPlayer?, current: AVPlayer, next: AVPlayer?, currentIndex: Int) {
    if rootView.topCatVideoView.topCatPlayerLayer.player != nil {
      rootView.topCatVideoView.removePlayers()
    }
    rootView.topCatVideoView.setPlayers(previous: previous, current: current, next: next)
    rootView.topCatVideoView.index = currentIndex
  }
  
  func nextCat() {
    guard let nextPlayer = rootView.topCatVideoView.nextPlayer else { return }
    rootView.topCatVideoView.index += 1
    var previous: AVPlayer?
    if let current = rootView.topCatVideoView.topCatPlayerLayer.player {
      previous = current
    } else if rootView.topCatVideoView.index > 1 {
      previous = playerForCat(index: rootView.topCatVideoView.index - 1)
    } else {
      previous = nil
    }
    let current = nextPlayer
    var next: AVPlayer?
    if rootView.topCatVideoView.index + 1 < catsCount {
      next = playerForCat(index: rootView.topCatVideoView.index + 1)
    } else {
      next = nil
    }
    rootView.topCatVideoView.setPlayers(previous: previous, current: current, next: next)
  }
  
  func previousCat() {
    guard let previousPlayer = rootView.topCatVideoView.previousPlayer else { return }
    rootView.topCatVideoView.index -= 1
    var previous: AVPlayer?
    if rootView.topCatVideoView.index > 0 {
      previous = playerForCat(index: rootView.topCatVideoView.index - 1)
    } else {
      previous = nil
    }
    let current = previousPlayer
    var next: AVPlayer?
    if let current = rootView.topCatVideoView.topCatPlayerLayer.player {
      next = current
    } else if rootView.topCatVideoView.index + 1 < catsCount {
      next = playerForCat(index: rootView.topCatVideoView.index + 1)
    } else {
      next = nil
    }
    rootView.topCatVideoView.setPlayers(previous: previous, current: current, next: next)
  }
  
  // Initial configuration
  func configure() {
    
    // Background audio
    do {
      try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
      try AVAudioSession.sharedInstance().setActive(true)
    } catch {
      print(error)
    }
  }
}
