//
//  AppDelegate.swift
//  CatsTV
//
//  Created by William Robinson on 2/14/17.
//
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    // Module setup
    let view = CatsViewController()
    let presenter = CatsPresenter()
    view.presenter = presenter
    presenter.view = view
    
    // Window setup
    window = UIWindow(frame: UIScreen.main.bounds)
    window!.rootViewController = view
    window!.makeKeyAndVisible()
    
    //Crashlytics Setup (standard metric as of now)
    Fabric.with([Crashlytics.self])
    
    return true
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    let rootVC = window!.rootViewController as! CatsViewController
    rootVC.rootView.topCatVideoView.startTopPlayer()
    rootVC.rootView.catsCollectionView.startPlayers()
    rootVC.presenter.appIsActive = true
    rootVC.presenter.provideCats()
    rootVC.userDidInteract()
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    let rootVC = window!.rootViewController as! CatsViewController
    rootVC.idleTimer?.invalidate()
    rootVC.presenter.appIsActive = false
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    let rootVC = window!.rootViewController as! CatsViewController
    rootVC.rootView.topCatVideoView.pauseTopPlayer()
    rootVC.rootView.catsCollectionView.pausePlayers()
  }
}

