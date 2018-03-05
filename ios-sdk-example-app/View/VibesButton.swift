//
//  VibesButton.swift
//  ios-sdk-example-app
//
//  Created by Jean-Michel Barbieri on 10/5/17.
//  Copyright © 2017 Vibes Media. All rights reserved.
//

import UIKit

class VibesButton: UIButton {
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.backgroundColor = UIColor.vibesButtonColor()
    self.translatesAutoresizingMaskIntoConstraints = false
    self.titleLabel?.textColor = .white
    self.titleLabel?.font = UIFont.systemFont(ofSize: 17)
    self.translatesAutoresizingMaskIntoConstraints = false
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
