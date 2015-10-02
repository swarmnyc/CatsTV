//
//  ViewController.swift
//  SWARMCats
//
//  Created by SWARMMAC01 on 9/29/15.
//  Copyright © 2015 SWARMNYC. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet var mainImageView: UIImageView!
    var entries = [Entry]()
    var index: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        for provider in ProviderCollection.Instance.Providers {
            provider.Fetch {
                data in
                for entry: Entry in data {
                    self.entries.append(entry)
                }

                if self.entries.count > 0 {
                    self.showPhoto()
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func showPhoto() {
        if let url = NSURL(string: entries[index].Url) {
            if let data = NSData(contentsOfURL: url) {
                mainImageView.image = UIImage(data: data)
            }
        }


        if index + 1 < self.entries.count {
            index = index + 1
        } else {
            index = 0
        }

        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "showPhoto", userInfo: nil, repeats: false)
    }
}

