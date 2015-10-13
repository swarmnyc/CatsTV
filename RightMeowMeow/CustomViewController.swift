//
//  CustomViewController.swift
//  RightMeowMeow
//
//  Created by Johann Kerr on 9/29/15.
//  Copyright © 2015 Johann Kerr. All rights reserved.
//

import UIKit

class CustomViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate{
    
    var collectionView: UICollectionView!
    var cats = [Entry]()
    let catApiURL = "https://www.reddit.com/r/cats/hot.json?limit=100"
    
    var index = 0
    var afterKey = ""
    var firstImageView : UIImageView?
    static let screenWidth :CGFloat = 1920
    static let screenHeight :CGFloat = 850
    
    
    
    
    
    func test(){
        print("called")
        if let URL = NSURL(string:self.cats[index++].ImgUrl){
            if let data = NSData(contentsOfURL: URL){
                print("called2")
                self.imageFadeIn(self.firstImageView!, image: UIImage.animatedImageWithData(data)!)
                
                
            }
            
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20.0, bottom: 0, right: 20.0)
        layout.itemSize = CGSize(width: 360, height: 230)
        //layout.minimumLineSpacing = 40
        layout.minimumLineSpacing = 30.0;
        layout.minimumInteritemSpacing = 30.0;
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        
        
       
        
        collectionView = UICollectionView(frame:CGRectMake(0,825,1920,230), collectionViewLayout: layout)
                
        collectionView.dataSource = self
        collectionView.delegate = self
        
        
        collectionView.registerClass(CatTrayViewCell.self, forCellWithReuseIdentifier:"Cell")
        self.view.addSubview(collectionView)
        
        
        
        
        
        
        
        /*
        let firstImageView = UIImageView(image:UIImage(named:"cat"))
        firstImageView.frame = CGRectMake(582, 162, 756, 756)
        self.view.addSubview(firstImageView)
        
        self.imageFadeIn(firstImageView, image: UIImage(named:"cat2")!)
        */
        EntryService.FetchAsnyc{
            
            self.cats = EntryService.GetEntries()
            
            self.collectionView.reloadData()
            
            
            dispatch_async(dispatch_get_main_queue()) {
                self.firstImageView = UIImageView(image:UIImage(named:"cat"))
                self.firstImageView!.frame = CGRectMake(0, 0, 1920, 800)
                self.firstImageView!.contentMode = UIViewContentMode.ScaleAspectFit
                self.firstImageView!.clipsToBounds = true
                
            
                
                self.view.addSubview(self.firstImageView!)
             
                // update some UI
                self.collectionView.reloadData()
                var timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "scrollView", userInfo: nil, repeats: true)
                self.test()

                
                
            
                
                
                
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
        secondImageView.frame = CGRectMake(0, 0, 1920, 800)
        //imageView.frame = CGRectMake(448 , 28, 1024, 1024)
        secondImageView.alpha = 0.0
        secondImageView.contentMode = UIViewContentMode.ScaleAspectFit
        secondImageView.clipsToBounds = true

        
        self.view.insertSubview(secondImageView, aboveSubview: imageView)
        
        UIView.animateWithDuration(2.0, delay: 0.0, options: .CurveEaseOut, animations: {
            //imageView.frame = CGRectMake(448, 28, 1024, 1024)
            
            
            }, completion: {_ in
                

                UIView.animateWithDuration(2.0, delay: 0.0, options: .CurveEaseOut, animations: {
                    imageView.alpha = 0.0
                    //secondImageView.frame = CGRectMake(448,28,1024,1024)
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
    
    func scrollView(){
        //print(self.collectionView.indexPathsForVisibleItems())
        
        var visibleItems =  []
        visibleItems = self.collectionView.indexPathsForVisibleItems()
        
        var currentItem : NSIndexPath = visibleItems.objectAtIndex(0) as! NSIndexPath
        var nextItem = NSIndexPath(forItem: currentItem.item + 1, inSection: 0)
        self.collectionView.scrollToItemAtIndexPath(nextItem, atScrollPosition: UICollectionViewScrollPosition.Top, animated: false)
    
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cats.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! CatTrayViewCell
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}