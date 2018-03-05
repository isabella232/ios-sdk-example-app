//
//  VibesLabel.swift
//  ios-sdk-example-app
//
//  Created by Jean-Michel Barbieri on 10/11/17.
//  Copyright © 2017 Vibes Media. All rights reserved.
//

import UIKit

class VibesLabel: UILabel {
  init(title: String, font: UIFont? = UIFont.systemFont(ofSize: 17), color: UIColor? = UIColor.vibesTitleLabel()) {
    super.init(frame: CGRect.null)
    self.text = NSLocalizedString(title, comment: "")
    self.textColor = color
    self.font = font
    self.translatesAutoresizingMaskIntoConstraints = false
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
