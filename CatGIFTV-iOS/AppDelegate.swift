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
        let presenter = CatsPresenter()
        view.presenter = presenter
        presenter.view = view
        
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
        rootVC.rootView.catsCollectionView.startPlayers()
        rootVC.presenter.appIsActive = true
        rootVC.presenter.provideCats()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        let rootVC = window!.rootViewController as! CatsViewController
        rootVC.presenter.appIsActive = false
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        let rootVC = window!.rootViewController as! CatsViewController
        rootVC.rootView.catsCollectionView.pausePlayers()
    }
}
