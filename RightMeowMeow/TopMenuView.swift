//
//  TopMenuView.swift
//  RightMeowMeow
//
//  Created by SWARMMAC01 on 10/16/15.
//  Copyright © 2015 Johann Kerr. All rights reserved.
//

import Foundation

private var myContext = 0
typealias Action = () -> Void

class TopMenuView: UIView {
    var ReportHandler: Action?
    var timer: NSTimer?
    var reportButton: UIButton?;
    var titleText: UITextView?;
    var originY: CGFloat?
    var newY: CGFloat?
    

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init() {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let menuHeight = screenSize.height * 0.1;
        let buttonWidth: CGFloat = 200;

        self.init(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height * 0.1))

        self.layer.zPosition = 1000
        self.backgroundColor = UIColor(red: 0.82, green: 0.82, blue: 0.81, alpha: 1)

        
        titleText = UITextView(frame: CGRect(x: 16, y: 16, width: screenSize.width - buttonWidth - 16, height: menuHeight - 32))
        
        self.addSubview(titleText!)

        reportButton = UIButton(type: UIButtonType.System) as UIButton
        reportButton!.frame = CGRect(x: screenSize.width - buttonWidth - 32, y: 16, width: buttonWidth, height: menuHeight - 32)

        reportButton!.setTitle("Report", forState: UIControlState.Normal)
        reportButton!.addTarget(self, action: "report:", forControlEvents: .AllEvents)
        self.addSubview(reportButton!)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }

    override func didUpdateFocusInContext(context: UIFocusUpdateContext,
                                          withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        //hide and show
        if originY == nil {
            //first
            self.originY = self.layer.position.y;
            self.newY = -self.frame.height + self.layer.position.y + 20
            
            UIView.animateWithDuration(0.5, delay: 1.0, options: UIViewAnimationOptions.TransitionNone ,animations: {
                self.layer.position.y = self.newY!
                self.alpha = 0.1
                }, completion: nil)
            
            //TODO: try to lose focus 
        } else {
            if (reportButton!.state == UIControlState.Focused && self.layer.position.y == self.newY) {
                UIView.animateWithDuration(0.5, animations: {
                    self.layer.position.y = self.originY!
                    self.alpha = 1
                    }, completion: nil)
            } else if (reportButton!.state != UIControlState.Focused && self.layer.position.y == self.originY) {
                UIView.animateWithDuration(0.5, animations: {
                    self.layer.position.y = self.newY!
                    self.alpha = 0.1
                    }, completion: nil)
            }
        }

        
    }

    func report(sender: UIButton) {
        ReportHandler!()
    }
    
    func setTitle(title: String) {
        titleText!.text = title;
    }
}
