//
//  MusicCatButton.swift
//
//
//  Created by William Robinson on 2/28/17.
//
//

import UIKit

class MusicCatButton: UIButton {
  
  // Delegation
  weak var inputDelegate: CatInputProtocol!
  
  // Initialization
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  convenience init() {
    self.init(frame: CGRect.zero)
    configure()
  }
  
  // Actions
  @objc func touched() {
    let url = URL(string: "music:")!
    if UIApplication.shared.canOpenURL(url) {
      UIApplication.shared.open(url, options: [:])
    }
  }
  
  // Initial configuration
  private func configure() {
    setImage(#imageLiteral(resourceName: "MusicCat"), for: .normal)
    addTarget(self, action: #selector(touched), for: .primaryActionTriggered)
  }
}
