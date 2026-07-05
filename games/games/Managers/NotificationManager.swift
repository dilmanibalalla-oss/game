import UserNotifications
import SwiftUI
import Combine

// 1. Order: Inherit from NSObject first, then the protocols
class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    
    private let center = UNUserNotificationCenter.current()
    
    override init() {
        super.init()
        // 2. Set the delegate so the app can handle notifications while open
        center.delegate = self
    }

    func requestPermission() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Permission granted")
            } else if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    func scheduleDailyNotification(at date: Date, title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "daily-reminder",
            content: content,
            trigger: trigger
        )
        
        center.removePendingNotificationRequests(withIdentifiers: ["daily-reminder"])
        center.add(request) { error in
            if let error = error {
                print("Error scheduling: \(error.localizedDescription)")
            }
        }
    }
}
