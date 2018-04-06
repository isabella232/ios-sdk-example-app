//
//  VibesFacade.swift
//  ios-sdk-example-app
//
//  Created by Jean-Michel Barbieri on 10/5/17.
//  Copyright © 2017 Vibes Media. All rights reserved.
//

import UIKit
import VibesPush

class VibesFacade: VibesAPIDelegate {
    fileprivate var registerDeviceCompletionHandler: ((String?, Error?) -> Void)?
    fileprivate var unregisterDeviceCompletionHandler: ((Error?) -> Void)?
    fileprivate var registerPushCompletionHandler: ((Error?) -> Void)?
    fileprivate var unregisterPushCompletionHandler: ((Error?) -> Void)?
    fileprivate var updateLocationCompletionHandler: ((Error?) -> Void)?

    init() {
        Vibes.shared.set(delegate: self)
    }
    
    /// Register the iOS device.
    /// - parameters :
    ///     - completionHandler: callback for the viewModel
    func registerDevice(completionHandler: @escaping (String?, Error?) -> Void) {
        registerDeviceCompletionHandler = completionHandler
        Vibes.shared.registerDevice()
    }
    
    /// Unregister the iOS device. If unregisterPush hasn't been called before,
    /// unregistering a device, will unregister push as well... clean plate!
    /// - parameters :
    ///     - completionHandler: callback for the viewModel
    func unregisterDevice(completionHandler: @escaping (Error?) -> Void) {
        unregisterDeviceCompletionHandler = completionHandler
        Vibes.shared.unregisterDevice()
    }
    
    /// Register the device for push notification.
    /// - parameters :
    ///     token -> Apple push notification token
    ///     completionHandler -> callback for the viewModel
    func registerPush(token: Data, completionHandler: @escaping (Error?) -> Void) {
        registerPushCompletionHandler = completionHandler
        Vibes.shared.setPushToken(fromData: token)
        Vibes.shared.registerPush()
    }
    
    /// Unregister the device for push notification.
    /// - parameters :
    ///     token -> Apple push notification token
    ///     completionHandler -> callback for the viewModel
    func unregisterPush(token: Data, completionHandler: @escaping (Error?) -> Void) {
        unregisterPushCompletionHandler = completionHandler
        Vibes.shared.unregisterPush()
    }
    
    /// Update the user location
    /// - parameters :
    ///     lat -> lattitude of the user
    ///     long -> longitude of the user
    ///     completionHandler -> callback for the viewModel
    func updateUserLocation(lat: Double, long: Double, completionHandler: @escaping (Error?) -> Void) {
        updateLocationCompletionHandler = completionHandler
        Vibes.shared.updateDevice(lat: lat, long: long)
    }
    
    ////////////////////////////////
    /// VibesAPIDelegate methods ///
    ////////////////////////////////
    
    func didRegisterDevice(deviceId: String?, error: Error?) {
       registerDeviceCompletionHandler?(deviceId, error)
    }
    
    func didUnregisterDevice(error: Error?) {
        unregisterDeviceCompletionHandler?(error)
    }
    
    func didRegisterPush(error: Error?) {
        registerPushCompletionHandler?(error)
    }
    
    func didUnregisterPush(error: Error?) {
        unregisterPushCompletionHandler?(error)
    }
    
    func didUpdateDeviceLocation(error: Error?) {
        updateLocationCompletionHandler?(error)
    }
}
