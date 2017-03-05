




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
    func store(cats: Set<Cat>) {
        guard !isScrolling else { return }
        let initialCatCount = catsCount
        for cat in cats {
            guard !self.cats.contains(cat) else { continue }
            self.cats.append(cat)
        }
        if !viewModel.isPopulating || initialCatCount == 0 {
            rootView.catsCollectionView.reloadData()
        }
        if catIndex > self.cats.count - 20 {
            viewModel.enableCatAcquisition()
        } else {
            viewModel.disableCatAcquisition()
            if viewModel.isPopulating {
                viewModel.completePopulating()
            }
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
        if catIndex + 10 > self.cats.count {
            viewModel.provideCats()
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
        if viewModel.isPopulating {
            viewModel.completePopulating()
        }
    }
    
    // Scrolling has finished
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




