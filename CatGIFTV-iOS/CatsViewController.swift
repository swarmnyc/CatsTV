//
//  CatsViewController.swift
//  CatsTV
//
//  Created by William Robinson on 3/2/17.
//
//

import UIKit
import SnapKit
import AVFoundation

// Defines commands sent from presenter to view
protocol CatsOutputProtocol: class {
    func store(cats: [Cat])
}

// Defines inputs in view
protocol CatInputProtocol: class {
    var catsCount: Int { get }
    var catIndex: Int { get }
    var isScrolling: Bool { get }
    func cat(index: Int) -> Cat
    func currentCatIndex(_ catIndex: Int)
    func userDidInteract()
    func setScrolling()
    func stoppedScrolling()
}

class CatsViewController: UIViewController {
    
    // Presenter
    var viewModel: CatsViewModelProtocol!
    
    // Cat input protocol
    var catsCount: Int {
        return cats.count
    }
    var catIndex: Int = 0
    var isScrolling = false
    
    // Subviews
    var rootView: CatsView {
        return view as! CatsView
    }
    // Properties
    lazy var cats: [Cat] = []
    var idleTimer: Timer?
    var isUserActive: Bool = true
    
    // Status bar
    public override var prefersStatusBarHidden: Bool {
        return !isUserActive
    }
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    // Set root view
    override func loadView() {
        view = CatsView()
    }
    // Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.retrieveCats()
        configure()
    }
    // Screen rotation
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        rootView.catsCollectionView.resizeCellsForOrientationChange()
    }
}

// Cats view protocol
extension CatsViewController: CatsOutputProtocol {
    // Store cats retrieved from Reddit
    func store(cats: [Cat]) {
        guard !isScrolling else { return }
        let updateIndex = self.cats.count
        self.cats.append(contentsOf: cats)
        
        print("••")
        print("cat: \(catIndex)\ncount: \(self.cats.count)")
        print("••")
        
        catIndex + 20 > self.cats.count ? viewModel.enableCatAcquisition() : viewModel.disableCatAcquisition()
        if updateIndex > 0 {
            rootView.catsCollectionView.update(with: cats, at: updateIndex)
        } else {
            guard self.cats.count > 0 else { return }
            rootView.catsCollectionView.reloadData()
            rootView.animateAppLaunch()
        }
    }
}

extension CatsViewController: CatInputProtocol {
    // Provide cat at the specified index
    func cat(index: Int) -> Cat {
        return cats[index]
    }
    // Set new current cat index
    func currentCatIndex(_ catIndex: Int) {
        if self.catIndex != catIndex {
            self.catIndex = catIndex
            if catIndex + 10 > self.cats.count {
                viewModel.retrieveCats()
            }
        }
    }
    
    // Idle timer for user touch
    func userDidInteract() {
        idleTimer?.invalidate()
        if !isUserActive {
            rootView.animateToActiveInterface()
            isUserActive = true
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                options: [.curveEaseOut, .allowUserInteraction],
                animations: {
                    self.setNeedsStatusBarAppearanceUpdate()
            })
        }
        idleTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in
            guard self.isUserActive else { return }
            self.rootView.animateToInactiveInterface()
            self.isUserActive = false
            UIView.animate(
                withDuration: 0.1,
                delay: 0,
                options: [.curveEaseOut, .allowUserInteraction],
                animations: {
                    self.setNeedsStatusBarAppearanceUpdate()
            })
        }
    }
    
    // Set state to scrolling
    func setScrolling() {
        isScrolling = true
    }
    
    // Set state to not scrolling
    func stoppedScrolling() {
        isScrolling = false
    }
}

private extension CatsViewController {
    // Initial configuration
    func configure() {
        // Delegation setup
        rootView.addDelegates(self)
        // Allow background audio for Apple Music
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
    }
}
