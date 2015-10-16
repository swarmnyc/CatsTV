//
//  CustomViewController.swift
//  RightMeowMeow
//
//  Created by Johann Kerr on 9/29/15.
//  Copyright © 2015 Johann Kerr. All rights reserved.
//

import UIKit

class CustomViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    static let screenWidth: CGFloat = 1920
    static let screenHeight: CGFloat = 850

    var collectionView: UICollectionView!
    var topMenuView: TopMenuView?;
    var cats = [Entry]()
    var imageIndex = 0
    var firstImageView: UIImageView?

    func loadImage() {
        print("loadCatImage -> \(imageIndex)")
        if let URL = NSURL(string: self.cats[imageIndex++].ImgUrl) {
            if let data = NSData(contentsOfURL: URL) {
                if imageIndex > self.cats.count-10{
                    print("fatch more")
                    EntryService.FetchMoreAsnyc({
                        entries in
                        for entry in entries{
                            self.cats.append(entry)
                            print(entry.ImgUrl)
                            print("fetching more")
                        }
                    })
                }
                
                var timeDuration = (UIImage.animatedImageWithData(data)?.duration)!
                self.imageSwitch(self.firstImageView!, image: UIImage.animatedImageWithData(data)!, duration: timeDuration)
            }
        }
        EntryService.FetchMoreAsnyc({
            entries in
            for entry in entries{
                self.cats.append(entry)
                print(entry.ImgUrl)
                print("fetching more")
            }
        })
        

        /*
            if let URL = NSURL(string:self.cats[index++].ImgUrl){

            if let data = NSData(contentsOfURL: URL){
            print("called2")

            //let timeDuration = UIImage.animatedImageWithData(data)?.duration
            //UIImage.duration(data)
            //self.imageFadeIn(self.firstImageView!, image: UIImage(data:data)!)
            //var timer = NSTimer.scheduledTimerWithTimeInterval((UIImage.animatedImageWithData(data)?.duration)!, target: self, selector: "scrollView", userInfo: nil, repeats: true)
            }
            }
        */
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        topMenuView = TopMenuView();
        topMenuView!.ReportHandler = self.HandleReport

        self.view.addSubview(topMenuView!)

        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20.0, bottom: 0, right: 20.0)
        layout.itemSize = CGSize(width: 360, height: 230)
        //layout.minimumLineSpacing = 40
        layout.minimumLineSpacing = 30.0;
        layout.minimumInteritemSpacing = 30.0;
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal


        collectionView = UICollectionView(frame: CGRectMake(0, 825, 1920, 230), collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.scrollEnabled = false
        collectionView.registerClass(CatTrayViewCell.self, forCellWithReuseIdentifier: "Cell")
        self.view.addSubview(collectionView)

        let leftswipeRecognizer = UISwipeGestureRecognizer(target: self, action: "leftSwipe")
        leftswipeRecognizer.direction = .Left
        self.view.addGestureRecognizer(leftswipeRecognizer)
        let rightswipeRecognizer = UISwipeGestureRecognizer(target: self, action: "rightSwipe")
        rightswipeRecognizer.direction = .Right
        self.view.addGestureRecognizer(rightswipeRecognizer)

        /*
        let firstImageView = UIImageView(image:UIImage(named:"cat"))
        firstImageView.frame = CGRectMake(582, 162, 756, 756)
        self.view.addSubview(firstImageView)
        
        self.imageFadeIn(firstImageView, image: UIImage(named:"cat2")!)
        */
        EntryService.FetchAsnyc {
            entries in
            for entry in entries {
                self.cats.append(entry)
                print(entry.ImgUrl)
            }

            dispatch_async(dispatch_get_main_queue()) {
                self.firstImageView = UIImageView(image: UIImage(named: "cat"))
                self.firstImageView!.frame = CGRectMake(0, 0, 1920, 800)
                self.firstImageView!.contentMode = UIViewContentMode.ScaleAspectFit
                self.firstImageView!.clipsToBounds = true
                self.view.addSubview(self.firstImageView!)

                // update some UI
                self.collectionView.reloadData()

                self.loadImage()
            }
        }

        //collectionView.backgroundColor = UIColor(patternImage: UIImage(named:"background")!)
        // Do any additional setup after loading the view, typically from a nib.
    }

    func imageSwitchAgain(imageView: UIImageView, image: UIImage) {
        imageView.image = image
       // scrollView(UICollectionViewScrollPosition.Left)
    }

    func imageSwitch(imageView: UIImageView, image: UIImage, duration: NSTimeInterval) {
        /*let secondImageView = UIImageView(image: image)
        secondImageView.frame = CGRectMake(0,0,1920,800)
        secondImageView.contentMode = UIViewContentMode.ScaleAspectFit
        secondImageView.clipsToBounds = true
        self.view.insertSubview(secondImageView, aboveSubview: imageView)
        //duration used to be 4.0
        */
        self.firstImageView?.image = image
        //self.scrollView()

        //secondImageView.removeFromSuperview()

        var timer = NSTimer.scheduledTimerWithTimeInterval(duration, target: self, selector: "loadImage", userInfo: nil, repeats: false)
    }

    func imageFadeIn(imageView: UIImageView, image: UIImage) {
        imageView.alpha = 1.0
        let secondImageView = UIImageView(image: image)
        secondImageView.frame = CGRectMake(0, 0, 1920, 800)
        //imageView.frame = CGRectMake(448 , 28, 1024, 1024)
        secondImageView.alpha = 1.0
        secondImageView.contentMode = UIViewContentMode.ScaleAspectFit
        secondImageView.clipsToBounds = true


        self.view.insertSubview(secondImageView, aboveSubview: imageView)

        UIView.animateWithDuration(2.0, delay: 0.0, options: .CurveEaseOut, animations: {
            //imageView.frame = CGRectMake(448, 28, 1024, 1024)


        }, completion: {
            _ in


            UIView.animateWithDuration(2.0, delay: 0.0, options: .CurveEaseOut, animations: {
                imageView.frame = CGRectMake(0, 0, 1920, 800)

                secondImageView.frame = CGRectMake(0, 0, 1920, 800)


            }, completion: {
                _ in
                //imageView.frame = CGRectMake(582, 162, 756, 756)
                //print(secondImageView.alpha)
                //print(imageView.alpha)


                secondImageView.removeFromSuperview()
                
                self.loadImage()

                //self.view.addSubview(imageView)
            })
        })
    }

    override func viewDidAppear(animated: Bool) {


    }

    func rightSwipe() {
        //scrollView()
        print("called")
       scrollView(.Right)
    }

    func leftSwipe() {
        print("called")
        //scrollView(UICollectionViewScrollPosition.Left)
        scrollView(.Left)

    }

    func scrollView(direction:UICollectionViewScrollPosition) {
        //print(self.collectionView.indexPathsForVisibleItems())

        var visibleItems = []
        visibleItems = self.collectionView.indexPathsForVisibleItems()
        if visibleItems.count != 0 {
            print("called3 for index \(imageIndex) ")
            var currentItem: NSIndexPath = visibleItems.objectAtIndex(0) as! NSIndexPath
            print("was visible -> \(self.cats[currentItem.row].ImgUrl)")
            var nextItem = NSIndexPath(forItem: currentItem.item + 1, inSection: 0)
            print("now visible -> \(self.cats[nextItem.row].ImgUrl)")

            
            self.collectionView.scrollToItemAtIndexPath(nextItem, atScrollPosition: UICollectionViewScrollPosition.Left, animated: true)
            //self.collectionView.scrollToItemAtIndexPath(visibleItems.objectAtIndex(1) as! NSIndexPath, atScrollPosition: UICollectionViewScrollPosition.Left, animated: true)
            if direction == UICollectionViewScrollPosition.Left {
                self.collectionView.scrollToItemAtIndexPath(nextItem, atScrollPosition: UICollectionViewScrollPosition.Left, animated: true)
                print("called left")

            } else if direction == UICollectionViewScrollPosition.Right {
                self.collectionView.scrollToItemAtIndexPath(nextItem, atScrollPosition: UICollectionViewScrollPosition.Right, animated: true)
                print("called right")

            }
        
//            if (self.cats.count > (index+1) )
//            {
//                self.collectionView.scrollToItemAtIndexPath(NSIndexPath( index: index+1),atScrollPosition: UICollectionViewScrollPosition.Left, animated: false);
//            }
        }
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cats.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! CatTrayViewCell
        //cell.imageCat.image = UIImage(named:"cat")
        if let URL = NSURL(string: cats[indexPath.row + 1].ImgUrl) {
            if let data = NSData(contentsOfURL: URL) {
                //cell.imageCat.image = UIImage(data:data)
                if URL.pathExtension!.lowercaseString == "gif" {
                    //cell.imageCat.image = UIImage.animatedImageWithData(data)

                    cell.imageCat.image = UIImage.animatedImageWithData(data)
                } else {
                    cell.imageCat.image = UIImage(data: data)
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

    func HandleReport() {
        if (imageIndex >= 0 && imageIndex < cats.count) {
            //Todo stop timer if forcus
            self.cats.removeAtIndex(imageIndex);
            self.collectionView.deleteItemsAtIndexPaths([NSIndexPath(forRow: imageIndex, inSection: 0)])
            imageIndex--;
            loadImage()
        }
    }
}