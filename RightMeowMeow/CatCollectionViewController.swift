//
//  CatCollectionViewController.swift
//  RightMeowMeow
//
//  Created by Johann Kerr on 9/29/15.
//  Copyright © 2015 Johann Kerr. All rights reserved.
//

import UIKit



private let reuseIdentifier = "Cell"


class CatCollectionViewController: UICollectionViewController {
    
    @IBOutlet var collection: UICollectionView!
    
    var cats = [Cat]()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("started")
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        //makeApiCall()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }
    func makeApiCall(){
        print("started")
        let catApiURL = "https://www.reddit.com/r/cats/hot.json?limit=100"
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
    
    func parseJsonData(data: NSData){
                
                
                
                var json = JSON(data: data)
                //print(json["data"]["children"][0])
                var j = 0
                
                
                for var i = 0; i<json["data"]["children"].count ; ++i{
            
            
            
            let cat = Cat()
            
            //cat.imgUrl =
            //print(json["data"]["children"][i]["data"]["preview"]["images"][i]["source"]["url"].stringValue)
            print(json["data"]["children"][i]["data"]["preview"]["images"][0]["source"]["url"])
            cat.imgUrl=json["data"]["children"][i]["data"]["preview"]["images"][0]["source"]["url"].stringValue
            
            self.cats.append(cat)
            
            
            
                }
        
        self.collection.reloadData()
                
                
                
                
              
                
    }
    

    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return cats.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        
   
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CatCell", forIndexPath: indexPath) as! CatViewCell
        
      
        cell.catPhoto.image = UIImage(named:"cat")
        
        /*
        let URL = NSURL(string:cats[indexPath.row].imgUrl)
        if let data = NSData(contentsOfURL: URL!){
            cell.catPhoto.image = UIImage(data:data)
            
        }
        */
        
        
      
        return cell
    }


    /*override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
    
       cell
    
        return cell
    }
    */

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
