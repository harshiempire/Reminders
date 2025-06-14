import UserNotifications

enum NotificationScheduler {
  /// Schedule (or re-schedule) a reminder
  static func schedule(_ rem: Reminder) {
    guard let id = rem.id?.uuidString,
          let date = rem.dateTime else { return }

    // Content
    let content = UNMutableNotificationContent()
    content.title = rem.title ?? ""
    content.body  = rem.note  ?? ""
    content.sound = .default
    content.categoryIdentifier = "REMINDER_CATEGORY"

    // Trigger (calendar, repeating if recurrenceRule exists)
    let comps = Calendar.current.dateComponents(
      [.year, .month, .day, .hour, .minute],
      from: date
    )
    let trigger = UNCalendarNotificationTrigger(
      dateMatching: comps,
      repeats: rem.recurrenceRule != nil
    )

    let req = UNNotificationRequest(
      identifier: id,
      content: content,
      trigger: trigger
    )
    UNUserNotificationCenter.current().add(req) { error in
      if let e = error { print("🔔 schedule error:", e) }
    }
  }

  /// Cancel any pending notification for this reminder
  static func cancel(_ rem: Reminder) {
    guard let id = rem.id?.uuidString else { return }
    UNUserNotificationCenter.current()
      .removePendingNotificationRequests(withIdentifiers: [id])
  }
}
