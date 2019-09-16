//
//  CatsViewModel.swift
//  CatsTV
//
//  Created by William Robinson on 3/4/17.
//
//

import Foundation

protocol CatsViewModelProtocol: class {
    var isLaunch: Bool { get }
    var isRetrievingCats: Bool { get }
    func completeLaunch()
    func retrieveCats()
    func stopRetrievingCats()
}

class CatsViewModel: CatsViewModelProtocol {
    
    // View
    weak var view: CatsOutputProtocol!
    
    // Properties
    var isLaunch: Bool = true
    var isRetrievingCats: Bool = false
    
    // Retrieve cats and store in cat bucket
    func retrieveCats(){
        isRetrievingCats = true
        Reddit.getCatURLs {
            cats in DispatchQueue.main.async {
                self.view.store(cats: cats)
            }
        }
    }
    
    func stopRetrievingCats() {
        isRetrievingCats = false
    }
    
    // Mark launch as complete
    func completeLaunch() {
        isLaunch = false
    }
}
