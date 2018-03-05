//
//  PushNotificationViewController.swift
//  ios-sdk-example-app
//
//  Created by Jean-Michel Barbieri on 10/6/17.
//  Copyright © 2017 Vibes Media. All rights reserved.
//

import UIKit

class PushNotificationViewController: UIViewController {
  fileprivate lazy var imageBackground: UIImageView = {
    var image = UIImageView(image: UIImage(named: "pushNotifImage"))
    image.translatesAutoresizingMaskIntoConstraints = false
    return image
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(red:0.73, green:0.80, blue:0.13, alpha:1.0)
    view.addSubview(imageBackground)
    setupConstraints()
  }
  
  fileprivate func setupConstraints() {
    view.addConstraint(NSLayoutConstraint(item: imageBackground, attribute: .centerX, relatedBy: .equal,
                                          toItem: view, attribute: .centerX,
                                          multiplier: 1.0, constant: 0.0))
    view.addConstraint(NSLayoutConstraint(item: imageBackground, attribute: .centerY, relatedBy: .equal,
                                          toItem: view, attribute: .centerY,
                                          multiplier: 1.0, constant: 0.0))
  }
}
