//
//  CatsPresenter.swift
//  CatsTV
//
//  Created by William Robinson on 2/16/17.
//
//

import Foundation

protocol CatsPresenterProtocol: class {
  var appIsActive: Bool { get set }
  func provideCats()
}

class CatsPresenter: CatsPresenterProtocol {
  
  // View
  weak var view: CatsOutputProtocol!
  
  // Properties
  var appIsActive = true
  
  // Retrieve cats
  func provideCats(){
    Reddit.getCatURLs { cats in
      DispatchQueue.main.async {
        self.view.store(cats: cats)
        guard self.appIsActive else { return }
        DispatchQueue.global(qos: .background).async {
          self.provideCats()
        }
      }
    }
  }
}
