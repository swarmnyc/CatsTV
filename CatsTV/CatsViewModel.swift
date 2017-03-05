//
//  CatsViewModel.swift
//  CatsTV
//
//  Created by William Robinson on 3/4/17.
//
//

import Foundation

protocol CatsViewModelProtocol: class {
    func retrieveCats()
    func provideCats()
    func enableCatAcquisition()
    func disableCatAcquisition()
}

class CatsViewModel: CatsViewModelProtocol {
    
    // View
    weak var view: CatsOutputProtocol!
    
    // Properties
    var catBucket: [Cat] = []
    var proceedWithCatAcquisition: Bool = true
    
    // Retrieve cats and store in cat bucket
    func retrieveCats(){
        Reddit.getCatURLs { cats in
            self.catBucket.append(contentsOf: cats)
            self.provideCats()
        }
    }
    
    // Provide bucketed cats then empty bucket
    func provideCats() {
        guard !catBucket.isEmpty else { return }
        DispatchQueue.main.async {
            self.view.store(cats: self.catBucket)
        }
    }
    
    // Allow more cats to be retrieved
    func enableCatAcquisition() {
        proceedWithCatAcquisition = true
    }
    
    // Prevent retrieval of additional cats
    func disableCatAcquisition() {
        proceedWithCatAcquisition = false
    }
}
