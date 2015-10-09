//
//  CarouselViewController.swift
//  RightMeowMeow
//
//  Created by Johann Kerr on 10/6/15.
//  Copyright © 2015 Johann Kerr. All rights reserved.
//

import UIKit

class CarouselViewController: UIViewController, iCarouselDataSource, iCarouselDelegate {
    let carousel = iCarousel()
    var i = 0
    
    var cats = [Entry]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.view.backgroundColor = UIColor.whiteColor()
        
        EntryService.FetchAsnyc{
            self.cats = EntryService.GetEntries()
            self.carousel.reloadData()
        }
        
        //let catRect:CGRect = CGRectMake(100, 100, self.view.frame.width/2, self.view.frame.height/2)
        
        self.carousel.frame = self.view.frame
        self.carousel.type = .InvertedTimeMachine
        self.carousel.delegate = self
        self.carousel.dataSource = self
        
        self.view.addSubview(carousel)
        print("carousel added")
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "update", userInfo: nil, repeats: true)
        //self.carousel.scrollToItemAtIndex(20, animated: true)
        
        
        

        // Do any additional setup after loading the view.
    }
    
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int
    {
        return cats.count
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView
    {
        
        var catView : UIImageView
        
        catView = UIImageView(frame: self.view.frame)
        catView.contentMode = UIViewContentMode.ScaleAspectFit
        catView.clipsToBounds = true
        if let URL = NSURL(string:cats[index].ImgUrl){
            if let data = NSData(contentsOfURL: URL){
                //catView.image = UIImage(data:data)
                
                
                
                if URL.pathExtension!.lowercaseString == "gif"{
                    catView.image = UIImage.animatedImageWithData(data)
                }else{
                    catView.image = UIImage(data:data)
                }
                
                 //cell.imageCat.image = UIImage.animatedImageWithData(data)
                
            }
            
        }
        
        
        return catView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func update(){
        
        //self.carousel.scrollByNumberOfItems(0, duration:3.0 )
        self.carousel.scrollToItemAtIndex(self.i, animated: true)
        
        
        self.i++
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
