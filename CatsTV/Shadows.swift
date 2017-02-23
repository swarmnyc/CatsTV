//
//  Shadows.swift
//  CatsTV
//
//  Created by William Robinson on 2/15/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import UIKit

extension CALayer {
  static func shadow(_ view: UIView) {
    view.layer.shadowRadius = view.frame.height / 10
    view.layer.shadowColor = UIColor(red: 18 / 255, green: 96 / 255, blue: 83 / 255, alpha: 1).cgColor
    view.layer.shadowOpacity = 0.7
  }
}
