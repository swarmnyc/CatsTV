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
    view.layer.shadowRadius = 10
    view.layer.shadowColor = UIColor.themeGreen.cgColor
    view.layer.shadowOpacity = 0.8
  }
}
