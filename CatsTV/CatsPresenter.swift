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
  
  // Properties
  
  func provideCats(){
    Reddit.getCatURLs { cats in
      DispatchQueue.main.async {
        self.view.store(cats: cats)
        self.view.showCats()
      }
    }
  }
}
