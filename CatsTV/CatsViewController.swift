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
  var isLaunch: Bool { get }
  var didPerformInitialLayout: Bool { get set }
  var isFullScreen: Bool { get set }
  var isScrolling: Bool { get }
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
  var isLaunch = true
  var didPerformInitialLayout = false
  var isFullScreen = false
  var isScrolling = false
  
  // Set custom root view
  override func loadView() {
    view = CatsView()
  }
  
  // Life cycle
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
    if isLaunch {
      rootView.animateOnLaunch()
    }
  }
}

// Cats view protocol
extension CatsViewController: CatsOutputProtocol {
  
  // Store cats retrieved from Reddit
  func store(cats: [Cat]) {
    print("🐈 got \(cats.count) cat urls from reddit 🐈")
    rootView.catsCollectionView.update(with: cats)
    if (isLaunch) {
      setVideoPlayersOnLaunch()
      userDidInteract()
      isLaunch = false
    }
  }
  
  // Configure video players on app launch
  private func setVideoPlayersOnLaunch() {
    if (cats.count > 1){
        let current = AVPlayer(url: cats[0].url)
        let next = AVPlayer(url: cats[1].url)
        current.isMuted = true
        next.isMuted = true
        rootView.topCatVideoView.setPlayers(previous: nil, current: current, next: next)
    }
    if (cats.count == 1){
        let current = AVPlayer(url: cats[0].url)
        current.isMuted = true
        rootView.topCatVideoView.setPlayers(previous: nil, current: current, next: nil)
    }
    rootView.catsCollectionView.reloadData()
    rootView.isUserInteractionEnabled = true
  }
}

extension CatsViewController: CatInputProtocol {
  
  // Number of stored cats
  var catsCount: Int {
    return cats.count
  }
  
  // Index of the cat video currently playing
  var currentVideoIndex: Int {
    return rootView.topCatVideoView.index
  }
  
  // Store new cats
  func append(cats: [Cat]) {
    self.cats.append(contentsOf: cats)
  }
  
  // Provide cat at the specified index
  func cat(index: Int) -> Cat {
    return cats[index]
  }
  
  // Provide video for cat at the specified index
  func playerForCat(index: Int) -> AVPlayer {
    return AVPlayer(url: cats[index].url)
  }
  
  // Switch between regular and full screen modes
  func toggleFullScreen() {
    isFullScreen ? rootView.makeRegularScreen() : rootView.makeFullScreen()
    isFullScreen = !isFullScreen
    rootView.toggleGestureRecognizersForScreenStatus()
  }
  
  // Collection view is scrolling
  func setScrolling() {
    isScrolling = true
  }
  
  // Collection view is not scrolling
  func setStoppedScrolling() {
    isScrolling = false
  }
  
  // Prevent automatic full screen mode when user has recently interacted
  func userDidInteract() {
    idleTimer?.invalidate()
    idleTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: false) { _ in
      guard !self.isFullScreen else { return }
      self.toggleFullScreen()
    }
  }
  
  // New video selected from collection view
  func catTapped(previous: AVPlayer?, current: AVPlayer, next: AVPlayer?, currentIndex: Int) {
    if rootView.topCatVideoView.topCatPlayerLayer.player != nil {
      rootView.topCatVideoView.removePlayers()
    }
    rootView.topCatVideoView.setPlayers(previous: previous, current: current, next: next)
    rootView.topCatVideoView.index = currentIndex
  }
  
  // Right swipe moves forward one video in full screen mode
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
  
  // Left swipe moves back one video in full screen mode
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
    
    // Delegation setup
    rootView.addDelegates(self)
    
    // Allow background audio for Apple Music
    do {
        try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
      try AVAudioSession.sharedInstance().setActive(true)
    } catch {
      print(error)
    }
  }
}
