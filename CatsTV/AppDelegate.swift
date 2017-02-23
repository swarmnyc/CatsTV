//
//  AppDelegate.swift
//  CatsTV
//
//  Created by William Robinson on 2/14/17.
//
//

import UIKit

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
    
    return true
  }
}

