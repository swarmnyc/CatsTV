//
//  Cat.swift
//  CatsTV
//
//  Created by William Robinson on 2/14/17.
//
//

import UIKit

struct Cat: Hashable {
    let url: URL
    let image: UIImage
    let hashValue: Int = UUID().hashValue
    
    static func ==(lhs: Cat, rhs: Cat) -> Bool {
        return lhs.url == rhs.url
    }
}
