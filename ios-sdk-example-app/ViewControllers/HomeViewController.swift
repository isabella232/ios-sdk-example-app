//
//  HomeViewController.swift
//  ios-sdk-example-app
//
//  Created by Jean-Michel Barbieri on 10/2/17.
//  Copyright © 2017 Vibes Media. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class HomeViewController: UIViewController {
  // Labels
  fileprivate let vibesDeviceId = VibesLabel(title: "homeView.deviceLabel")
  fileprivate let vibesDeviceIdValue = VibesLabel(title: "", font: UIFont.systemFont(ofSize: 15),
                                                 color: UIColor.vibesValueLabel())
  fileprivate let pushRegisteredLabel = VibesLabel(title: "homeView.pushunregistered", color: .red)
  fileprivate let tokenLabelTitle = VibesLabel(title: "homeView.appleTokenLabel")
  
  fileprivate lazy var tokenLabelValue: VibesLabel = {
    var label = VibesLabel(title: "-", font: UIFont.systemFont(ofSize: 10), color: UIColor.vibesValueLabel())
    label.numberOfLines = 0
    label.lineBreakMode = NSLineBreakMode.byCharWrapping
    return label
  }()

  // Buttons
  fileprivate let registerButton = VibesButton()
  fileprivate let registerPushButton = VibesButton()
  fileprivate let updateLocationButton = VibesButton()
  
  // Image
  fileprivate lazy var imageBackground: UIImageView = {
    var image = UIImageView(image: UIImage(named: "background"))
    image.translatesAutoresizingMaskIntoConstraints = false
    return image
  }()
  
  fileprivate let bag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    updateLocationButton.setTitle(NSLocalizedString("homeView.updateLocationButton", comment: ""), for: .normal)
    view.backgroundColor = .white
    view.addSubview(vibesDeviceId)
    view.addSubview(vibesDeviceIdValue)
    view.addSubview(tokenLabelTitle)
    view.addSubview(pushRegisteredLabel)
    view.addSubview(tokenLabelValue)
    view.addSubview(registerButton)
    view.addSubview(registerPushButton)
    view.addSubview(updateLocationButton)
    view.addSubview(imageBackground)
    setupConstraints()
    setupObservers()
  }
  
  fileprivate func setupObservers() {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let viewModel = HomeViewModel()
    
    _ = viewModel.regDevBtnTitleSubj.asDriver().drive(self.registerButton.rx.title())
    _ = viewModel.regPushBtnTitleSubj.asDriver().drive(self.registerPushButton.rx.title())
    _ = viewModel.deviceIdValueSubj.asDriver().drive(self.vibesDeviceIdValue.rx.text)
    
    // Register to viewModel registerPushButton.state Observer
    _ = viewModel.pushButtonEnableStateSubj.asObservable()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: {[weak self] value in
        guard let _self = self else { return }
        _self.registerPushButton.isEnabled = value
        _self.registerPushButton.backgroundColor = value ? UIColor.vibesButtonColor() : UIColor.vibesValueLabel()
      })
      .disposed(by: bag)
    
    _ = viewModel.updateLocButtonEnableStateSubj.asObservable()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: {[weak self] value in
        guard let _self = self else { return }
        _self.updateLocationButton.isEnabled = value
        _self.updateLocationButton.backgroundColor = value ? UIColor.vibesButtonColor() : UIColor.vibesValueLabel()
      })
      .disposed(by: bag)
    
    // Register to viewModel registerPush title Observer
    _ = viewModel.regPushLabelTitleSubj.asObservable()
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: {[weak self] value in
            guard let _self = self else { return }
            _self.pushRegisteredLabel.text = value.0
            _self.pushRegisteredLabel.textColor = value.1
        })
        .disposed(by: bag)
    
    // Observer for APNS push token
    appDelegate.tokenObserver
        .map { $0.map { String(format: "%02.2hhx", $0) }.joined()}
        .bind(to: self.tokenLabelValue.rx.text)
        .disposed(by: bag)
    
    // Button actions
    self.registerButton.rx.tap.bind { viewModel.registerOrUnregisterDevice() }.disposed(by: bag)
    self.registerPushButton.rx.tap.bind { viewModel.registerOrUnregisterPush() }.disposed(by: bag)
    self.updateLocationButton.rx.tap.bind { viewModel.updateLocation() }.disposed(by: bag)
  }
  
  /// Setup constraints for every UI elements added to the view
  fileprivate func setupConstraints() {
    // VibesDeviceID title label
    self.view.addConstraint(NSLayoutConstraint(item: vibesDeviceId, attribute: .leading, relatedBy: .equal,
                                           toItem: view, attribute: .leading,
                                           multiplier: 1.0, constant: 20.0))
    self.view.addConstraint(NSLayoutConstraint(item: vibesDeviceId, attribute: .top, relatedBy: .equal,
                                           toItem: view, attribute: .top,
                                           multiplier: 1.0, constant: 100.0))
    // VibesDeviceID value label
    self.view.addConstraint(NSLayoutConstraint(item: vibesDeviceIdValue, attribute: .leading, relatedBy: .equal,
                                               toItem: vibesDeviceId, attribute: .leading,
                                               multiplier: 1.0, constant: 0.0))
    self.view.addConstraint(NSLayoutConstraint(item: vibesDeviceIdValue, attribute: .top, relatedBy: .equal,
                                               toItem: vibesDeviceId, attribute: .bottom,
                                               multiplier: 1.0, constant: 10.0))
    // AppleToken title label
    self.view.addConstraint(NSLayoutConstraint(item: tokenLabelTitle, attribute: .leading, relatedBy: .equal,
                                               toItem: vibesDeviceId, attribute: .leading,
                                               multiplier: 1.0, constant: 0.0))
    self.view.addConstraint(NSLayoutConstraint(item: tokenLabelTitle, attribute: .top, relatedBy: .equal,
                                               toItem: vibesDeviceIdValue, attribute: .bottom,
                                               multiplier: 1.0, constant: 20))
    // AppleToken status (registered PUSH status)
    self.view.addConstraint(NSLayoutConstraint(item: pushRegisteredLabel, attribute: .leading, relatedBy: .equal,
                                               toItem: tokenLabelTitle, attribute: .trailing,
                                               multiplier: 1.0, constant: 10.0))
    self.view.addConstraint(NSLayoutConstraint(item: pushRegisteredLabel, attribute: .top, relatedBy: .equal,
                                               toItem: tokenLabelTitle, attribute: .top,
                                               multiplier: 1.0, constant: 0.0))
    // AppleToken value label
    self.view.addConstraint(NSLayoutConstraint(item: tokenLabelValue, attribute: .leading, relatedBy: .equal,
                                               toItem: vibesDeviceId, attribute: .leading,
                                               multiplier: 1.0, constant: 0.0))
    self.view.addConstraint(NSLayoutConstraint(item: tokenLabelValue, attribute: .top, relatedBy: .equal,
                                               toItem: tokenLabelTitle, attribute: .bottom,
                                               multiplier: 1.0, constant: 10.0))
     // Register device button
    self.view.addConstraint(NSLayoutConstraint(item: registerButton, attribute: .top, relatedBy: .equal,
                                                toItem: tokenLabelValue, attribute: .bottom,
                                                multiplier: 1.0, constant: 40))
    self.view.addConstraint(NSLayoutConstraint(item: registerButton, attribute: .centerX, relatedBy: .equal,
                                                toItem: view, attribute: .centerX,
                                                multiplier: 1.0, constant: 0.0))
    self.view.addConstraint(NSLayoutConstraint(item: registerButton, attribute: .height, relatedBy: .equal,
                                               toItem: nil, attribute: .notAnAttribute,
                                               multiplier: 1.0, constant: 60.0))
    self.view.addConstraint(NSLayoutConstraint(item: registerButton, attribute: .width, relatedBy: .equal,
                                               toItem: view, attribute: .width,
                                               multiplier: 0.90, constant: 0.0))
     // Register push button
    self.view.addConstraint(NSLayoutConstraint(item: registerPushButton, attribute: .top, relatedBy: .equal,
                                               toItem: registerButton, attribute: .bottom,
                                               multiplier: 1.0, constant: 20))
    self.view.addConstraint(NSLayoutConstraint(item: registerPushButton, attribute: .centerX, relatedBy: .equal,
                                               toItem: view, attribute: .centerX,
                                               multiplier: 1.0, constant: 0.0))
    self.view.addConstraint(NSLayoutConstraint(item: registerPushButton, attribute: .height, relatedBy: .equal,
                                               toItem: nil, attribute: .notAnAttribute,
                                               multiplier: 1.0, constant: 60.0))
    self.view.addConstraint(NSLayoutConstraint(item: registerPushButton, attribute: .width, relatedBy: .equal,
                                               toItem: view, attribute: .width,
                                               multiplier: 0.90, constant: 0.0))

    // Update location button
    self.view.addConstraint(NSLayoutConstraint(item: updateLocationButton, attribute: .top, relatedBy: .equal,
                                               toItem: registerPushButton, attribute: .bottom,
                                               multiplier: 1.0, constant: 20))
    self.view.addConstraint(NSLayoutConstraint(item: updateLocationButton, attribute: .centerX, relatedBy: .equal,
                                               toItem: view, attribute: .centerX,
                                               multiplier: 1.0, constant: 0.0))
    self.view.addConstraint(NSLayoutConstraint(item: updateLocationButton, attribute: .height, relatedBy: .equal,
                                               toItem: nil, attribute: .notAnAttribute,
                                               multiplier: 1.0, constant: 60.0))
    self.view.addConstraint(NSLayoutConstraint(item: updateLocationButton, attribute: .width, relatedBy: .equal,
                                               toItem: view, attribute: .width,
                                               multiplier: 0.90, constant: 0.0))
    // Image background
    self.view.addConstraint(NSLayoutConstraint(item: imageBackground, attribute: .centerX, relatedBy: .equal,
                                               toItem: view, attribute: .centerX,
                                               multiplier: 1.0, constant: 0.0))
    self.view.addConstraint(NSLayoutConstraint(item: imageBackground, attribute: .bottom, relatedBy: .equal,
                                               toItem: view, attribute: .bottom,
                                               multiplier: 1.0, constant: -50.0))
  }
}
