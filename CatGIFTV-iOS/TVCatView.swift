//
//  TVCatView.swift
//  CatsTV
//
//  Created by William Robinson on 3/3/17.
//
//

import UIKit

class TVCatView: UIView {
    
    // Initialization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    // Drawing
    override func draw(_ rect: CGRect) {
        StyleKit.drawTVCat()
    }
}
