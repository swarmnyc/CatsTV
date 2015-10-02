//
//  CatViewCell.swift
//  RightMeowMeow
//
//  Created by Johann Kerr on 9/29/15.
//  Copyright © 2015 Johann Kerr. All rights reserved.
//

import UIKit

class CatViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var catPhoto: UIImageView!
    var imageCat: UIImageView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageCat = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        imageCat.contentMode = UIViewContentMode.ScaleAspectFill
        imageCat.clipsToBounds = true
        contentView.addSubview(imageCat)
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
