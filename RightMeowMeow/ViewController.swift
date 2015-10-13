//
//  ViewController.swift
//  RightMeowMeow
//
//  Created by Johann Kerr on 9/29/15.
//  Copyright © 2015 Johann Kerr. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource  {
    
    var collectionView: UICollectionView!
    var cats = [Entry]()
    let catApiURL = "https://www.reddit.com/r/cats/hot.json?limit=100"
    
    
    var afterKey = ""
   
    
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 1400, height: 1000)
        //layout.minimumLineSpacing = 40
        layout.minimumLineSpacing = 100.0;
        layout.minimumInteritemSpacing = 100.0;
        
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
       
        
        //collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.registerClass(CatViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        collectionView.backgroundColor = UIColor(patternImage: UIImage(named:"background")!)
        /*
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        collectionView.backgroundView?.addSubview(blurEffectView)
        */
        self.view.addSubview(collectionView)
        //makeApiCall()
        
        
       
        
       
        
        
        
        
        
        
        
        EntryService.FetchAsnyc{ entries in
            for entry in entries{
                self.cats.append(entry)
            }
            
            self.collectionView.reloadData()
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        
    }
    
    func makeApiCall(){
        print("started")
        
        let request = NSURLRequest(URL: NSURL(string:catApiURL)!)
        let urlSession = NSURLSession.sharedSession()
        let task = urlSession.dataTaskWithRequest(request,completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error!.localizedDescription)
            }
            // Parse JSON data
            self.parseJsonData(data!)
            
            
            // Reload table view
            dispatch_async(dispatch_get_main_queue(), {
                //self.tableView.reloadData()
                
            })
        })
        task.resume()
        
    }
    
    func loadMoreCats(){
        print("loading more cats")
        
        
        var loadingUrl = catApiURL + "&after=" + afterKey
        print(loadingUrl)
        let request = NSURLRequest(URL: NSURL(string:loadingUrl)!)
        let urlSession = NSURLSession.sharedSession()
        let task = urlSession.dataTaskWithRequest(request,completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error!.localizedDescription)
            }
            // Parse JSON data
            self.parseJsonData(data!)
            
            
            // Reload table view
            dispatch_async(dispatch_get_main_queue(), {
                //self.tableView.reloadData()
                
            })
        })
        task.resume()
        
    }
    
    func parseJsonData(data: NSData){
        
        
        
        var json = JSON(data: data)
        //print(json["data"]["children"][0])
        //var j = 0
        afterKey = json["data"]["after"].stringValue
        
        
        for var i = 0; i<json["data"]["children"].count ; ++i{
            
            
            
//            let cat = Entry()
//            
//            //cat.imgUrl =
//            print(json["data"]["children"][i]["data"]["preview"]["images"][i]["source"]["url"].stringValue)
//            let urlattempt = (json["data"]["children"][i]["data"]["preview"]["images"][0]["source"]["url"]).stringValue
//            if urlattempt != "null"{
//                cat.imgUrl = urlattempt
//            }
//            //cat.imgUrl=json["data"]["children"][i]["data"]["preview"]["images"][0]["source"]["url"].stringValue
//            
//            
//            
//            self.cats.append(cat)
            
            
            
        }
        
        self.collectionView.reloadData()
        
        
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cats.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! CatViewCell
        //cell.imageCat.image = UIImage(named:"cat")
        if let URL = NSURL(string:cats[indexPath.row].ImgUrl){
            if let data = NSData(contentsOfURL: URL){
                //cell.imageCat.image = UIImage(data:data)
                if URL.pathExtension!.lowercaseString == "gif"{
                    cell.imageCat.image = UIImage.animatedImageWithData(data)
                }else{
                    cell.imageCat.image = UIImage(data:data)
                }
                //let catImage = UIImage.animatedImageWithData(data)
                //cell.imageCat.image = UIImage.animatedImageWithData(data)

                
                
            }
            
        
        }

    
        
        cell.backgroundColor = UIColor.orangeColor()
        return cell
    }
        



}

