//
//  AppDelegate.swift
//  ios-sdk-example-app
//
//  Created by Jean-Michel Barbieri on 10/2/17.
//  Copyright © 2017 Vibes Media. All rights reserved.
//

import UIKit
import VibesPush
import UserNotifications
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    fileprivate let navigationController = UINavigationController()
    public let tokenObserver = ReplaySubject<Data>.create(bufferSize: 1)
    
    // Constants
    fileprivate let kAppKey = "[YOUR APP KEY HERE]" /// Change the value with the one provided by Vibes
    fileprivate let kClientDataKey = "client_app_data"
    fileprivate let kClientCustomDataKey = "client_custom_data"
    fileprivate let kDeepLinkKey = "deep_link"
    fileprivate let kPushDeepLinkView = "pushView"
    
    // ViewControllers
    fileprivate let deepLinkViewController = PushNotificationViewController()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Vibes.configure(appId: kAppKey)
        
        // Push notification subscription
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                } else {
                    // Not the point of this example app
                }
            }
        } else {
            let notificationSettings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            application.registerUserNotificationSettings(notificationSettings)
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        if let window = window {
            window.backgroundColor = UIColor.white
            navigationController.viewControllers = [HomeViewController()]
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Following is used to display the token and save it in the PasteBoard
        let userDefault = UserDefaults.standard
        userDefault.setValue(deviceToken, forKey: ExampleConstant.APNS_TOKEN.rawValue)
        userDefault.synchronize()
        
        tokenObserver.onNext(deviceToken)
        
        // You can here register push, or if the push registration depends on the user being logged in or not, you can
        // add the logic here
        Vibes.shared.setPushToken(fromData: deviceToken)
        // If the user is logged in then ...
        // Vibes.shared.registerPush(completion: <#T##((VibesResult<Void>) -> Void)?##((VibesResult<Void>) -> Void)?##(VibesResult<Void>) -> Void#>)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // reset badging counter
        application.applicationIconBadgeNumber = 0;
    }
    
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if (notificationSettings.types != .none) {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Depending on your application logic, you could call unregister push here
        // Vibes.shared.unregisterPush(completion: <#T##((VibesResult<Void>) -> Void)?##((VibesResult<Void>) -> Void)?##(VibesResult<Void>) -> Void#>)
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        receivePushNotif(userInfo: response.notification.request.content.userInfo)
        completionHandler()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        receivePushNotif(userInfo: userInfo)
        completionHandler(.newData)
    }
    
    /// When the user clicks on a push notif, two events will be sent to Vibes backend: .launch, .clickthru events.
    /// If you specify a value for 'deep_link' in client_app_data, you can redirect the user to the viewcontrollers of
    /// your choice when he clicks on the push notification. The deep_link format is free
    /// (best practice:{nameApp}://{viewcontrollers}{%parameters}
    fileprivate func receivePushNotif(userInfo: [AnyHashable : Any]) {
        Vibes.configure(appId: kAppKey)
        Vibes.shared.receivedPush(with: userInfo)
        if let customdata = userInfo[kClientCustomDataKey] as? [String: Any] {
            // Do something with client_custom_data
        }
        
        // Over simplified deep_link mechanism, but you get the idea.
        guard let client_data = userInfo[kClientDataKey] as? [String: Any],
            let deepLink = client_data[kDeepLinkKey] as? String
            else { return }
        if (deepLink == kPushDeepLinkView) {
            self.navigationController.pushViewController(deepLinkViewController, animated: true)
        }
    }
}

