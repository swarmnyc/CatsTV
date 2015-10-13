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
    
    var index = 0
    var afterKey = ""
    var firstImageView : UIImageView?
    
    
    
    
    
    func test(){
        print("called")
        if let URL = NSURL(string:self.cats[index++].ImgUrl){
            if let data = NSData(contentsOfURL: URL){
                print("called2")
                self.imageFadeIn(self.firstImageView!, image: UIImage(data: data)!)
                
                
            }
            
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        let firstImageView = UIImageView(image:UIImage(named:"cat"))
        firstImageView.frame = CGRectMake(582, 162, 756, 756)
        self.view.addSubview(firstImageView)
        
        self.imageFadeIn(firstImageView, image: UIImage(named:"cat2")!)
        */
        EntryService.FetchAsnyc{
            
            self.cats = EntryService.GetEntries()
            //print(self.cats)
            
            dispatch_async(dispatch_get_main_queue()) {
                self.firstImageView = UIImageView(image:UIImage(named:"cat"))
                self.firstImageView!.frame = CGRectMake(582, 162, 756, 756)
                self.view.addSubview(self.firstImageView!)
                
                /*let alert = UIAlertController(title: "Alert", message: "Message", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                */
                // update some UI
                
                self.test()
      
//                    if let URL = NSURL(string:self.cats[index].ImgUrl){
//                        if let data = NSData(contentsOfURL: URL){
//                            self.imageFadeIn(firstImageView, image: UIImage(data:data)!)
//                            
//                        }
//                    }
        
                
                
            
                
                
                
               /* for index in 0...5{
                    
                    
                    if let URL = NSURL(string:self.cats[index].ImgUrl){
                        if let data = NSData(contentsOfURL: URL){
                            //cell.imageCat.image = UIImage(data:data)
                            if URL.pathExtension!.lowercaseString == "gif"{
                                self.imageFadeIn(firstImageView, image: UIImage.animatedImageWithData(data)!)
                                print("gif image")
                            }else{
                                self.imageFadeIn(firstImageView, image: UIImage(data:data)!)
                                print("regular image")
                                
                            }
                            
                        }
                        
                        
                        
                        
                        
                    }
                    
                    
                    
                    
                }*/
                
                
            }
           


            
            
            
        
           
            
            
        }
        
       

        
        
        //collectionView.backgroundColor = UIColor(patternImage: UIImage(named:"background")!)
        
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func imageFadeIn(imageView: UIImageView, image: UIImage){
        imageView.alpha = 1.0
        let secondImageView = UIImageView(image: image)
        secondImageView.frame = CGRectMake(582, 162, 756, 756)
        //imageView.frame = CGRectMake(448 , 28, 1024, 1024)
        secondImageView.alpha = 0.0
        
        self.view.insertSubview(secondImageView, aboveSubview: imageView)
        
        UIView.animateWithDuration(2.0, delay: 0.0, options: .CurveEaseOut, animations: {
            imageView.frame = CGRectMake(448, 28, 1024, 1024)
            
            
            }, completion: {_ in
                

                UIView.animateWithDuration(2.0, delay: 0.0, options: .CurveEaseOut, animations: {
                    imageView.alpha = 0.0
                    secondImageView.frame = CGRectMake(448,28,1024,1024)
                    secondImageView.alpha = 1.0
                    
                    
                    }, completion: {_ in
                        //imageView.frame = CGRectMake(582, 162, 756, 756)
                        print(secondImageView.alpha)
                        print(imageView.alpha)
                        imageView.image = secondImageView.image
                        self.test()
                        secondImageView.removeFromSuperview()
                        //self.view.addSubview(imageView)
                })
                
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
            

            
            
            
        }
        
        self.collectionView.reloadData()
        
        
        
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}