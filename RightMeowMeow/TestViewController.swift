//
//  CarouselViewController.swift
//  RightMeowMeow
//
//  Created by Johann Kerr on 10/6/15.
//  Copyright © 2015 Johann Kerr. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    var cats = ["AAA","BBBB","CCC"]
    
    var currentIndex = 0;
    var topMenuView : TopMenuView?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topMenuView = TopMenuView();
        topMenuView!.ReportHandler = self.HandleReport
        
        self.view.addSubview(topMenuView!)
        
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let menuHeight = screenSize.height*0.1;
        let buttonWidth : CGFloat = 200;
        
        let button = UIButton(type: UIButtonType.System) as UIButton
        button.frame = CGRect(x: screenSize.width - buttonWidth - 32 , y: 300, width: buttonWidth, height: menuHeight)
        
        button.backgroundColor = UIColor.blueColor()
        button.setTitle("Test", forState: UIControlState.Normal)
        
        self.view.addSubview(button)
    }
    
    func HandleReport(){
        if(currentIndex>=0 && currentIndex < cats.count){
            self.cats.removeAtIndex(currentIndex);
            // UI Update
        }
    }
}
