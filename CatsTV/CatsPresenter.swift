//
//  CatsPresenter.swift
//  CatsTV
//
//  Created by William Robinson on 2/16/17.
//
//

import Foundation

protocol CatsPresenterProtocol: class {
  func provideCats()
}

class CatsPresenter: CatsPresenterProtocol {
  
  // View
  weak var view: CatsViewProtocol!
  
  func provideCats(){
    Reddit.getCatURLs { cats in
      DispatchQueue.main.async {
        self.view.store(cats: cats)
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 2) {
          self.provideCats()
        }
      }
    }
  }
}
