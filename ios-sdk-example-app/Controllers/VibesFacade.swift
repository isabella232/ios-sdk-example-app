//
//  VibesFacade.swift
//  ios-sdk-example-app
//
//  Created by Jean-Michel Barbieri on 10/5/17.
//  Copyright © 2017 Vibes Media. All rights reserved.
//

import UIKit
import VibesPush

class VibesFacade {
  /// Register the iOS device. This called should be done after
  /// the user log in (vibes customer app logic).
  /// - parameters : (Bool, String) -> Void, Bool (success/failure), String(error)
  func registerDevice(completionHandler: @escaping (Bool, String, String) -> Void) {
    Vibes.shared.registerDevice { result in // VibesResult<Credential>
      if case let .success(credential) = result {
        print("--> Register Device --> Success (deviceId: \(credential.deviceId), authToken: \(credential.authToken))")
        completionHandler(true, credential.deviceId, "")
        /// This is where you could pass along the vibes_device_id (here credential.deviceId) to your backend.endpoint.
        // TODO: Call your backend endpoint and pass the vibes_device_id.
      } else if case let .failure(error) = result {
        var desc: String
        switch error {
        case .other(let other) :
          desc = other
        case .authFailed(let auth):
          desc = auth
        default:
          desc = "Unknown"
        }
        print("--> Register Device --> Failure: \(desc)")
        completionHandler(false, "", desc)
      }
    }
  }
  
  /// Unregister the iOS device. If unregisterPush hasn't been called before,
  /// unregistering a device, unregister push as well... clean plate!
  /// - parameters : (Bool, String) -> Void, Bool (success/failure), String(error)
  func unregisterDevice(completionHandler: @escaping (Bool, String) -> Void) {
    Vibes.shared.unregisterDevice { result in // VibesResult<Void>
      if case .success(_) = result {
        print("--> Unregister Device -> Success")
        completionHandler(true, "")
      } else if case let .failure(error) = result {
        var desc: String
        switch error {
        case .other(let other) :
          desc = other
        case .authFailed(let auth):
          desc = auth
        default:
          desc = "Unknown"
        }
        print("--> Unregister Device -> Failure: \(desc)")
        completionHandler(false, desc)
      }
    }
  }
  
  /// Register the apple push token in Vibes plateform.
  /// - parameters :
  ///     token -> Apple push notification token
  ///     (Bool, String) -> Void, Bool (success/failure), String(error)
  func registerPush(token: Data, completionHandler: @escaping (Bool, String) -> Void) {
    Vibes.shared.setPushToken(fromData: token)
    Vibes.shared.registerPush { result in
      if case .success(_) = result {
        print("--> Register PUSH --> Success")
        completionHandler(true, "")
      } else if case .failure(let error) = result {
        print("--> Register PUSH --> Failure: \(error)")
        completionHandler(false, error.localizedDescription)
      }
    }
  }
  
  /// Unregister the apple push token in Vibes plateform.
  /// - parameters :
  ///     token -> Apple push notification token
  ///     (Bool, String) -> Void, Bool (success/failure), String(error)
  func unregisterPush(token: Data, completionHandler: @escaping (Bool, String) -> Void) {
    Vibes.shared.unregisterPush { result in
      if case .success(_) = result {
        print("--> Unregister PUSH --> Success")
        completionHandler(true, "")
      } else if case .failure(let error) = result {
        print("--> Unregister PUSH --> Failure: \(error)")
        completionHandler(false, error.localizedDescription)
      }
    }
  }
    
  /// Unregister the apple push token in Vibes plateform.
  /// - parameters :
  ///     token -> Apple push notification token
  ///     (Bool, String) -> Void, Bool (success/failure), String(error)
    func updateUserLocation(location: (lat: Double, long: Double), completionHandler: @escaping (Bool, String) -> Void) {
      Vibes.shared.updateDevice(completion: { result in
        if case .success(_) = result {
            print("--> Update User Location --> Success")
            completionHandler(true, "")
        } else if case .failure(let error) = result {
            print("--> Update User Location --> Failure: \(error)")
            completionHandler(false, error.localizedDescription)
        }
      }, location: location)
  }
}
