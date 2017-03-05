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
    var isPopulating: Bool { get }
    func retrieveCats()
    func provideCats()
    func enableCatAcquisition()
    func disableCatAcquisition()
    func completeLaunch()
    func completePopulating()
}

class CatsViewModel: CatsViewModelProtocol {
    
    // View
    weak var view: CatsOutputProtocol!
    
    // Properties
    var catBucket: Set<Cat> = []
    var proceedWithCatAcquisition: Bool = true
    var isLaunch: Bool = true
    var isPopulating: Bool = true
    
    // Retrieve cats and store in cat bucket
    func retrieveCats(){
        Reddit.getCatURLs { cats in
            if self.isPopulating {
                self.catBucket = cats
                self.provideCats()
            } else {
                self.catBucket.formUnion(cats)
            }
            guard self.proceedWithCatAcquisition else { return }
            self.retrieveCats()
        }
    }
    
    // Provide bucketed cats then empty bucket
    func provideCats() {
        guard !catBucket.isEmpty else {
            retrieveCats()
            return
        }
        DispatchQueue.main.async {
            self.view.store(cats: self.catBucket)
            self.catBucket = []
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
    
    // Mark launch as complete
    func completeLaunch() {
        isLaunch = false
    }
    
    // MarK initial cat populating as complete
    func completePopulating() {
        isPopulating = false
    }
}
