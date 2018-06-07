//
//  AppDelegate.swift
//  ios-sdk-example-app
//
//  Copyright © 2017 Vibes Media. All rights reserved.

import UIKit
import UserNotifications
import VibesPush

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, VibesAPIDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]? = nil) -> Bool {
    Vibes.configure(appId: "YOUR_APP_ID")
    Vibes.shared.set(delegate: self)

    Vibes.shared.registerDevice()

    if #available(iOS 10.0, *) {
      self.requestNotificationPermissionsIOS10(application: application)
    } else {
      self.requestNotificationPermissionsIOS9(application: application)
    }

    return true
  }

  // MARK: - All Push Notifications

  // Handle successful retrieval of a push token from Apple
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Vibes.shared.setPushToken(fromData: deviceToken)
    Vibes.shared.registerPush()
    Vibes.shared.updateDevice(lat: 41.8686839, long: -87.8075274)
  }

  // MARK: - iOS 9 Push Notifications

  // Request permission to display user notifications
  func requestNotificationPermissionsIOS9(application: UIApplication) {
    let notificationSettings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
    application.registerUserNotificationSettings(notificationSettings)
  }

  // Callback when user grants or denies permission to display user notifications. If granted: register for remote notifications.
  func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
    if notificationSettings.types != .none {
      application.registerForRemoteNotifications()
    }
  }

  // Callback for when a remote notification is received.
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    Vibes.shared.receivedPush(with: userInfo)
    self.handlePushNotification(userInfo: userInfo)

    completionHandler(.newData)
  }

  // MARK: - iOS 10+ Push Notifications

  // Request permission to display user notifications. If granted: register for remote notifications.
  @available(iOS 10.0, *)
  func requestNotificationPermissionsIOS10(application: UIApplication) {
    UNUserNotificationCenter.current().delegate = self
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, _) in
      if granted {
        DispatchQueue.main.async {
          UIApplication.shared.registerForRemoteNotifications()
        }
      }
    }
  }

  // Callback for when a remote notification is received.
  @available(iOS 10.0, *)
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Swift.Void) {
    let userInfo = response.notification.request.content.userInfo
    Vibes.shared.receivedPush(with: userInfo)
    self.handlePushNotification(userInfo: userInfo)

    completionHandler()
  }

  // MARK: - Application-specific handling of push notification

  func handlePushNotification(userInfo: [AnyHashable: Any]) {
    print("received push with details: \(userInfo)")
  }

  // MARK: - VibesAPIDelegate

  // Callback for when the device is registered with Vibes
  func didRegisterDevice(deviceId: String?, error: Error?) {
    print("didRegisterDevice - \(successOrError(error, fallback: "deviceId: \(deviceId ?? ""))"))")
  }

  // Callback for when the device is unregistered with Vibes
  func didUnregisterDevice(error: Error?) {
    print("didUnregisterDevice - \(successOrError(error))")
  }

  // Callback for when the device's push token is sent to Vibes
  func didRegisterPush(error: Error?) {
    print("didRegisterPush - \(successOrError(error))")
  }

  // Callback for when the device's push token is removed from Vibes
  func didUnregisterPush(error: Error?) {
    print("didUnregisterPush - \(successOrError(error))")
  }

  // Callback for when the device's location is updated
  func didUpdateDeviceLocation(error: Error?) {
    print("didUpdateDeviceLocation - \(successOrError(error))")
  }

  // A small utility function to either display an error or success message
  private func successOrError(_ error: Error?, fallback: String = "success") -> String {
    if let error = error {
      return "error: \(error)"
    } else {
      return fallback
    }
  }
}
