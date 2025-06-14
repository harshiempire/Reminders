import Foundation
import UserNotifications

/// Utility functions for scheduling and managing local notifications.
struct NotificationScheduler {
    static func schedule(_ reminder: Reminder) {
        guard let id = reminder.id, let date = reminder.dateTime else { return }
        let content = UNMutableNotificationContent()
        content.title = reminder.title ?? ""
        if let note = reminder.note { content.body = note }
        content.sound = .default

        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: reminder.recurrenceRule != nil)

        let request = UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let err = error { print("Notification scheduling error:", err) }
        }
    }

    static func cancel(_ reminder: Reminder) {
        if let id = reminder.id {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
        }
    }

    static func reschedule(_ reminder: Reminder) {
        cancel(reminder)
        schedule(reminder)
    }
}
