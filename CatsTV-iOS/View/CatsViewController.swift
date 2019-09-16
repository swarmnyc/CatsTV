




import UIKit
import SnapKit
import AVFoundation

// Defines commands sent from presenter to view
protocol CatsOutputProtocol: class {
    func store(cats: Set<Cat>)
}

// Defines inputs in view
protocol CatInputProtocol: class {
    var catsCount: Int { get }
    var catIndex: Int { get }
    func cat(index: Int) -> Cat
    func currentCatIndex(_ catIndex: Int)
    func userDidInteract()
    func finishedScrolling()
}

class CatsViewController: UIViewController {
    
    // Presenter
    var viewModel: CatsViewModelProtocol!
    
    // Cat input protocol
    var catsCount: Int {
        return cats.count
    }
    var catIndex: Int = 0
    
    // Subviews
    var rootView: CatsView {
        return view as! CatsView
    }
    // Properties
    var cats: [Cat] = []
    var catBucket: Set<Cat> = []
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
    func store(cats: Set<Cat>) {
        catBucket.formUnion(cats)
        if !cats.isEmpty, !rootView.catsCollectionView.isDragging, !rootView.catsCollectionView.isDecelerating {
            rootView.catsCollectionView.performBatchUpdates({
                for cat in self.catBucket {
                    guard !self.cats.contains(cat) else { continue }
                    self.cats.append(cat)
                    self.rootView.catsCollectionView.insertItems(at: [IndexPath(item: self.catsCount - 1, section: 0)])
                }
                self.catBucket = []
            })
        }
        if catIndex > self.cats.count - 20 {
            viewModel.retrieveCats()
        }
        else {
            viewModel.stopRetrievingCats()
        }
        if viewModel.isLaunch {
            rootView.animateAppLaunch()
            viewModel.completeLaunch()
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
        self.catIndex = catIndex
        if catIndex > self.cats.count - 20, !viewModel.isRetrievingCats {
            viewModel.retrieveCats()
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
    
    // Update collection view with new cats when scrolling has finished
    func finishedScrolling() {
        guard !catBucket.isEmpty else { return }
        rootView.catsCollectionView.performBatchUpdates({
            for cat in self.catBucket {
                guard !self.cats.contains(cat) else { continue }
                self.cats.append(cat)
                self.rootView.catsCollectionView.insertItems(at: [IndexPath(item: self.catsCount - 1, section: 0)])
            }
            self.catBucket = []
        })
    }
}

private extension CatsViewController {
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




