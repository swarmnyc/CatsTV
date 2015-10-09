//
//  CustomViewController.swift
//  RightMeowMeow
//
//  Created by Johann Kerr on 9/29/15.
//  Copyright © 2015 Johann Kerr. All rights reserved.
//

import UIKit

class CustomViewController: UIViewController{
    
    var collectionView: UICollectionView!
    var cats = [Entry]()
    let catApiURL = "https://www.reddit.com/r/cats/hot.json?limit=100"
    
    
    var afterKey = ""
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let firstImageView = UIImageView(image:UIImage(named:"background"))
        firstImageView.frame = CGRectMake(582, 162, 756, 756)
        self.view.addSubview(firstImageView)
        
        EntryService.FetchAsnyc{
            self.cats = EntryService.GetEntries()
            print(self.cats)
            self.imageFadeIn(firstImageView, image: UIImage(named:"cat")!)
            for cat in self.cats{
                
               
                
            }
            
            
        }
       
        
        
        
        
        
        
        
        
        
        
        //collectionView.backgroundColor = UIColor(patternImage: UIImage(named:"background")!)
        
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func imageFadeIn(imageView: UIImageView, image: UIImage){
        print("called")
        let secondImageView = UIImageView(image: image)
        secondImageView.frame = CGRectMake(582, 162, 756, 756)
        
        secondImageView.alpha = 0.0
        self.view.insertSubview(secondImageView, aboveSubview: imageView)
        
        
        
        UIView.animateWithDuration(1.0, delay: 1.0, options: .CurveEaseOut, animations: {
            print("called")
            //imageView.frame = CGRectMake(448 , 28, 1024, 1024)
            
            secondImageView.alpha = 1.0
            }, completion: {_ in
                
                imageView.image = secondImageView.image
                secondImageView.removeFromSuperview()
                
        })
        
        
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

