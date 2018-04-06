//
//  NotificationService.swift
//  richPush
//
//  Created by Jean-Michel Barbieri on 3/21/18.
//  Copyright © 2018 Vibes Media. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    fileprivate let kClientDataKey = "client_app_data"
    fileprivate let kImageUrlKey = "image_url"
    fileprivate let kVideoUrlKey = "video_url"
    fileprivate let kRichContentIdentifier = "richContent"

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        if let bestAttemptContent = bestAttemptContent {
            if let clientData = bestAttemptContent.userInfo[kClientDataKey] as? [String: Any] {

                var attachmentUrl: URL?
                if let attachmentString = clientData[kImageUrlKey] as? String {
                    attachmentUrl = URL(string: attachmentString)
                } else if let attachmentString = clientData[kVideoUrlKey] as? String {
                    attachmentUrl = URL(string: attachmentString)
                } else {
                    // Nothing to download
                    return
                }

                let session = URLSession(configuration: URLSessionConfiguration.default)

                if let attachmentUrl = attachmentUrl {
                    let attachmentDownloadTask = session.downloadTask(with: attachmentUrl, completionHandler: { (location, response, error) in
                        if let location = location {
                            let tmpDirectory = NSTemporaryDirectory()
                            let tmpFile = "file://".appending(tmpDirectory).appending(attachmentUrl.lastPathComponent)
                            let tmpUrl = URL(string: tmpFile)!
                            do {
                                try FileManager.default.moveItem(at: location, to: tmpUrl)
                                if let attachment = try? UNNotificationAttachment(identifier: self.kRichContentIdentifier, url: tmpUrl) {
                                    bestAttemptContent.attachments = [attachment]
                                }
                            } catch {
                                print("An exception was caught while downloading the rich content!")
                            }
                        }
                        // Serve the notification content
                        self.contentHandler!(self.bestAttemptContent!)
                    })
                    attachmentDownloadTask.resume()
                }
            }
        }
    }

    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
