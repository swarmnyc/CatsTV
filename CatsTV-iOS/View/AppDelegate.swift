




import UIKit
import Fabric
import Crashlytics


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Module setup
        let view = CatsViewController()
        let viewModel = CatsViewModel()
        view.viewModel = viewModel
        viewModel.view = view
        
        // Window setup
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.rootViewController = view
        window!.makeKeyAndVisible()
        
        // Fabric setup
        Fabric.with([Crashlytics.self])
        
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        let rootVC = window!.rootViewController as! CatsViewController
        rootVC.rootView.catsCollectionView.setCurrentPlayer()
        rootVC.viewModel.retrieveCats()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        let rootVC = window!.rootViewController as! CatsViewController
        rootVC.rootView.catsCollectionView.removeCurrentPlayer()
    }
}




