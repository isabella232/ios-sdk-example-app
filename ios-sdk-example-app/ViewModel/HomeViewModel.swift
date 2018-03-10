//
//  HomeViewModel.swift
//  ios-sdk-example-app
//
//  Created by Jean-Michel Barbieri on 10/5/17.
//  Copyright © 2017 Vibes Media. All rights reserved.
//

import UIKit
import RxSwift

class HomeViewModel: NSObject {
    /// Vibes network controller
    fileprivate let vibesController = VibesFacade()
    
    let regDevBtnTitleSubj = Variable<String>("")
    let regPushBtnTitleSubj = Variable<String>("")
    let regPushLabelTitleSubj = Variable(("", UIColor.red))
    let deviceIdValueSubj = Variable<String>("")
    let pushButtonEnableStateSubj = Variable<Bool>(false)
    let updateLocButtonEnableStateSubj = Variable<Bool>(false)
    
    /// Register device/push states
    fileprivate var deviceRegistered = false
    fileprivate var devicePushRegistered = false
    
    fileprivate let bag = DisposeBag()
    
    public override init() {
        super.init()
        
        regDevBtnTitleSubj.value = NSLocalizedString("homeView.registerButton", comment: "")
        regPushLabelTitleSubj.value = (NSLocalizedString("homeView.pushunregistered", comment: ""), UIColor.red)
        regPushBtnTitleSubj.value = NSLocalizedString("homeView.registerPushButton", comment: "")
        deviceIdValueSubj.value = NSLocalizedString("homeView.deviceLabelDefaultValue", comment: "")
    }
    
    /// RegisterDevice button action
    public func registerOrUnregisterDevice() {
        self.deviceRegistered ? self.unregisterDevice() : self.registerDevice()
    }
    
    /// RegisterPush button action
    public func registerOrUnregisterPush() {
        self.devicePushRegistered ? self.unregisterPush() : self.registerPush()
    }
    
    /// Update location action
    public func updateLocation() {
        // Fake location info
        self.vibesController.updateUserLocation(lat: 48.866667, long: 2.333333) { error in
            if (error == nil) {
                print("--> Update User Location --> Success")
            } else {
                print("--> Update User Location --> Failure: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    /// When the user clicks on the register device button, this method is called.
    /// It will notify (through the output observable) the UI to update the register button text
    /// when the call succeeds. For this example app, we don't handle error cases but the same
    /// logic could be applied: push into an Observable any error and the UI would be responsible to
    /// display it (popup...)
    fileprivate func registerDevice() {
        self.vibesController.registerDevice(completionHandler: {[weak self] (deviceId, error) in
            guard let _self = self, error == nil, let device_id = deviceId
            else {
                // Could display the error
                print("--> Register Device --> Failure: \(String(describing: error?.localizedDescription))")
                return
            }
            print("--> Register Device --> Success (deviceId: \(device_id))")
            _self.regDevBtnTitleSubj.value = NSLocalizedString("homeView.unregisterButton", comment: "")
            _self.deviceIdValueSubj.value = device_id
            _self.deviceRegistered = true
            _self.pushButtonEnableStateSubj.value = true
            _self.updateLocButtonEnableStateSubj.value = true
        })
    }
    
    /// When the user clicks on the unregister device button, this method is called.
    /// It will notify (through the output observable) the UI to update (when the call succeeds):
    /// - register device button text
    /// - register push button state
    /// - register push button text
    /// - register push label text and color
    /// For this example app, we don't handle error cases but the same logic could be applied: push
    /// into an Observable any error and the UI would be responsible to display it (popup...)
    fileprivate func unregisterDevice() {
        self.vibesController.unregisterDevice(completionHandler: {[weak self] error in
            guard let _self = self, error == nil
            else {
                // Could display the error
                print("--> Unregister Device -> Failure: \(String(describing: error?.localizedDescription))")
                return
            }
            print("--> Unregister Device -> Success")
            _self.regDevBtnTitleSubj.value = NSLocalizedString("homeView.registerButton", comment: "")
            _self.deviceIdValueSubj.value = NSLocalizedString("homeView.deviceLabelDefaultValue", comment: "")
            _self.regPushBtnTitleSubj.value = NSLocalizedString("homeView.registerPushButton", comment: "")
            _self.regPushLabelTitleSubj.value = (NSLocalizedString("homeView.pushunregistered", comment: ""), UIColor.red)
            _self.deviceRegistered = false
            // Unregistering device does a unregister push as well on the backend side.
            // Having a separate unregisterPush allows Vibes customer app to manager user preference
            // individually (unregister push with having the device registered allows the app to keep
            // recording app events such as 'launch')
            _self.devicePushRegistered = false
            _self.pushButtonEnableStateSubj.value = false
            _self.updateLocButtonEnableStateSubj.value = false
        })
    }
    
    /// When the user clicks on the register push button, this method is called.
    /// It will notify (through the output observable) the UI to update (when the call succeeds):
    /// - the register push button text value
    /// - the register push label value
    /// For this example app, we don't handle error cases but the same
    /// logic could be applied: push into an Observable any error and the UI would be responsible to
    /// display it (popup...)
    fileprivate func registerPush() {
        let userDefault = UserDefaults.standard
        let tokenData = userDefault.data(forKey: ExampleConstant.APNS_TOKEN.rawValue)
        if let token = tokenData {
            self.vibesController.registerPush(token: token, completionHandler: {[weak self] error in
                guard let _self = self, error == nil
                else {
                    print("--> Register PUSH --> Failure: \(String(describing: error?.localizedDescription))")
                    return
                }
                print("--> Register PUSH --> Success")
                _self.regPushLabelTitleSubj.value = (NSLocalizedString("homeView.pushregistered", comment: ""), UIColor.green)
                _self.regPushBtnTitleSubj.value = NSLocalizedString("homeView.unregisterPushButton", comment: "")
                _self.devicePushRegistered = true
            })
        }
    }
    
    /// When the user clicks on the unregister push button, this method is called.
    /// It will notify (through the output observable) the UI to update (when the call succeeds):
    /// - the register push button text value
    /// - the register push label value
    /// For this example app, we don't handle error cases but the same
    /// logic could be applied: push into an Observable any error and the UI would be responsible to
    /// display it (popup...)
    fileprivate func unregisterPush() {
        let userDefault = UserDefaults.standard
        let tokenData = userDefault.data(forKey: ExampleConstant.APNS_TOKEN.rawValue)
        if let token = tokenData {
            self.vibesController.unregisterPush(token: token, completionHandler: {[weak self] error in
                guard let _self = self, error == nil
                else {
                    print("--> Unregister PUSH --> Failure: \(String(describing: error?.localizedDescription))")
                    return
                }
                print("--> Unregister PUSH --> Success")
                _self.regPushLabelTitleSubj.value = (NSLocalizedString("homeView.pushunregistered", comment: ""), UIColor.red)
                _self.regPushBtnTitleSubj.value = NSLocalizedString("homeView.registerPushButton", comment: "")
                _self.devicePushRegistered = false
            })
        }
    }
}
