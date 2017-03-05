//
//  AppDelegate.swift
//  CatGIFTV-iOS
//
//  Created by William Robinson on 3/2/17.
//
//

import UIKit
import Fabric
import Crashlytics


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
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
        rootVC.viewModel.enableCatAcquisition()
        rootVC.viewModel.retrieveCats()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        let rootVC = window!.rootViewController as! CatsViewController
        rootVC.viewModel.disableCatAcquisition()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        let rootVC = window!.rootViewController as! CatsViewController
        rootVC.rootView.catsCollectionView.removeCurrentPlayer()
    }
}
