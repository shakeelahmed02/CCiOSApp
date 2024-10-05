//
//  LocalNotification.swift
//  CambourneCrescent
//
//  Created by Ahmed, Shakeel on 27/07/2024.
//

import Foundation
import UIKit
import UserNotifications

enum NotificationTriggerOption {
    case date(date: Date, repeats: Bool)
    case time(timeInterval: TimeInterval, repeats: Bool)
}

struct AnyNotificationContent {
    let id: String
    let title: String
    let body: String?
    let sound: Bool
    let badge: Int?
    
    init(id: String = UUID().uuidString, title: String, body: String? = nil, sound: Bool = true, badge: Int? = nil) {
        self.id = id
        self.title = title
        self.body = body
        self.sound = sound
        self.badge = badge
    }
}

@MainActor
final class LocalNotifications {
    
    static let shared = LocalNotifications()
    private init() {}
    
    private let instance = UNUserNotificationCenter.current()
    private let maxNotificationLimit = 63
    private var notificationsCount = 1
    
    func scheduleNotificaitons() async {
        LocalNotifications.shared.removeAllPendingNotifications()
        LocalNotifications.shared.removeAllDeliveredNotifications()
        notificationsCount = 1
        let datasource = await Global.shared.getSalahTimings()
        for data in datasource {
            let date = data.date
            
            guard
                let fajr = data.namaz.first(where: { $0.name.lowercased() == "fajr"}),
                let dhohr = data.namaz.first(where: { $0.name.lowercased() == "dhohr"}),
                let asr = data.namaz.first(where: { $0.name.lowercased() == "asr"}),
                let magrib = data.namaz.first(where: { $0.name.lowercased() == "magrib"}),
                let isha = data.namaz.first(where: { $0.name.lowercased() == "isha"}) else { continue }
            
            await scheduleNotificaiton(salah: fajr, salahDate: date)
            await scheduleNotificaiton(salah: dhohr, salahDate: date)
            await scheduleNotificaiton(salah: asr, salahDate: date)
            await scheduleNotificaiton(salah: magrib, salahDate: date)
            await scheduleNotificaiton(salah: isha, salahDate: date)
        }
        /* LocalNotifications.shared.getPendingNotificationRequests { nots in
            for not in nots {
                print("\(not.content.title) - \(not.trigger)")
            }
        }*/
    }
    
    private func scheduleNotificaiton(salah: SalahModel, salahDate: String) async {
        let currentYear = Calendar.current.component(.year, from: Date())
        let salahTime = salah.jamat
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let salahDateString = "\(salahDate) \(currentYear) \(salahTime)"
        guard let salahDate = dateFormatter.date(from: salahDateString) else { return }
        let salahNotTime = salahDate.timeIntervalSinceNow - 15*60
        let notDate = Date(timeIntervalSinceNow: salahNotTime)
        if salahNotTime > 0, !salah.loc.isEmpty, notificationsCount < maxNotificationLimit {
            try? await LocalNotifications.shared.scheduleNotification(
                content: AnyNotificationContent(
                    title: "\(salah.name) @\(salah.loc) in 15 mins",
                    body: "حَيَّ عَلَىٰ ٱلْفَلَاحِ",
                    sound: Global.shared.soundOn,
                    badge: nil
                ),
                trigger: .time(timeInterval: salahNotTime, repeats: false)
            )
            notificationsCount += 1
        }
    }
    
    /// Requests the user’s authorization to allow local and remote notifications for your app.
    @discardableResult func requestAuthorization(options: UNAuthorizationOptions = [.alert, .sound, .badge]) async throws -> Bool {
        try await instance.requestAuthorization(options: options)
    }
    
    /// Retrieves the notification authorization settings for your app.
    ///
    /// - .authorized = User previously granted permission for notifications
    /// - .denied = User previously denied permission for notifications
    /// - .notDetermined = Notification permission hasn't been asked yet.
    /// - .provisional = The application is authorized to post non-interruptive user notifications (iOS 12.0+)
    /// - .ephemeral = The application is temporarily authorized to post notifications - available to App Clips only (iOS 14.0+)
    ///
    /// - Returns: User's authorization status
    func getNotificationStatus() async throws -> UNAuthorizationStatus {
        return await withCheckedContinuation({ continutation in
            instance.getNotificationSettings { settings in
                continutation.resume(returning: settings.authorizationStatus)
                return
            }
        })
    }
        
    /// Schedule a local notification
    func scheduleNotification(content: AnyNotificationContent, trigger: NotificationTriggerOption) async throws {
        try await scheduleNotification(
            id: content.id,
            title: content.title,
            body: content.body,
            sound: content.sound,
            badge: content.badge,
            trigger: trigger)
    }
    
    /// Schedule a local notification
    func scheduleNotification(id: String = UUID().uuidString, title: String, body: String? = nil, sound: Bool = true, badge: Int? = nil, trigger: NotificationTriggerOption) async throws {
        let notificationContent = getNotificationContent(title: title, body: body, sound: sound, badge: badge)
        let notificationTrigger = getNotificationTrigger(option: trigger)
        try await addNotification(identifier: id, content: notificationContent, trigger: notificationTrigger)
    }
    
    /// Cancel all pending notifications (notifications that are in the queue and have not yet triggered)
    func removeAllPendingNotifications() {
        instance.removeAllPendingNotificationRequests()
    }
    
    /// Remove all delivered notifications (notifications that have previously triggered)
    func removeAllDeliveredNotifications() {
        instance.removeAllDeliveredNotifications()
    }
    
    /// Remove notifications by ID
    ///
    /// - Parameters:
    ///   - ids: ID associated with scheduled notification.
    ///   - pending: Cancel pending notifications (notifications that are in the queue and have not yet triggered)
    ///   - delivered: Remove delivered notifications (notifications that have previously triggered)
    func removeNotifications(ids: [String], pending: Bool = true, delivered: Bool = true) {
        if pending {
            instance.removePendingNotificationRequests(withIdentifiers: ids)
        }
        if delivered {
            instance.removeDeliveredNotifications(withIdentifiers: ids)
        }
    }
    
    func getPendingNotificationRequests(completion: @escaping ([UNNotificationRequest]) -> Void) {
        return instance.getPendingNotificationRequests(completionHandler: completion)
    }
}

// MARK: PRIVATE

private extension LocalNotifications {
    
    private func getNotificationContent(title: String, body: String?, sound: Bool, badge: Int?) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        if let body {
            content.body = body
        }
        if sound {
            content.sound = .default
        }
        if let badge {
            content.badge = NSNumber(integerLiteral: badge)
        }
        return content
    }
    
    private func getNotificationTrigger(option: NotificationTriggerOption) -> UNNotificationTrigger {
        switch option {
        case .date(date: let date, repeats: let repeats):
            let components = Calendar.current.dateComponents([.second, .minute, .hour, .day, .month, .year], from: date)
            return UNCalendarNotificationTrigger(dateMatching: components, repeats: repeats)
        case .time(timeInterval: let timeInterval, repeats: let repeats):
            return UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: repeats)
        }
    }
    
    private func addNotification(identifier: String?, content: UNNotificationContent, trigger: UNNotificationTrigger) async throws {
        let request = UNNotificationRequest(
            identifier: identifier ?? UUID().uuidString,
            content: content,
            trigger: trigger)
        
        try await instance.add(request)
    }
    
}
