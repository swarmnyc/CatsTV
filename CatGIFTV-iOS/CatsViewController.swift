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
    func cat(index: Int) -> Cat
    func userDidInteract()
}

public class CatsViewController: UIViewController {
    
    // Presenter
    var presenter: CatsPresenterProtocol!
    
    // Subviews
    var rootView: CatsView {
        return view as! CatsView
    }
    
    // Properties
    lazy var cats: [Cat] = []
    var idleTimer: Timer?
    var isUserActive = true
    
    // Set root view
    override open func loadView() {
        view = CatsView()
    }
    
    // Life cycle
    override open func viewDidLoad() {
        super.viewDidLoad()
        presenter.provideCats()
        configure()
    }
    
    // Screen rotation
    func screenRotated() {
        switch UIDevice.current.orientation {
        case .portrait:
            rootView.catsCollectionView.layoutCellsForPortraitOrientation()
        case .landscapeLeft, .landscapeRight:
            rootView.catsCollectionView.layoutCellsForLandscapeOrientation()
        default:
            return
        }
    }
}

// Cats view protocol
extension CatsViewController: CatsOutputProtocol {
    
    // Store cats retrieved from Reddit
    func store(cats: [Cat]) {
        let startIndex = self.cats.count
        self.cats.append(contentsOf: cats)
        if startIndex > 0 {
            rootView.catsCollectionView.update(with: cats, at: startIndex)
        } else {
            rootView.catsCollectionView.reloadData()
            rootView.animateAppLaunch()
        }
    }
}

extension CatsViewController: CatInputProtocol {
    
    // Number of stored cats
    var catsCount: Int {
        return cats.count
    }
    
    // Provide cat at the specified index
    func cat(index: Int) -> Cat {
        return cats[index]
    }
    
    // Idle timer for user touch
    func userDidInteract() {
        idleTimer?.invalidate()
        if !isUserActive {
            rootView.animateToActiveInterface()
            isUserActive = true
        }
        idleTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in
            guard self.isUserActive else { return }
            self.rootView.animateToInactiveInterface()
            self.isUserActive = false
        }
    }
    
    // Initial configuration
    func configure() {
        
        // Delegation setup
        rootView.addDelegates(self)
        
        // Observe screen rotation
        NotificationCenter.default.addObserver(self, selector: #selector(screenRotated), name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
    }
}
