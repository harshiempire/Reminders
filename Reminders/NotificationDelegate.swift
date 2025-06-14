import UserNotifications

/// Catches incoming notifications so they’re shown when the app is foregrounded,
/// and lets you handle actions (like “Snooze”) later on.
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
  override init() {
    super.init()
    UNUserNotificationCenter.current().delegate = self
  }

  // Called when a notification arrives while the app is running in the foreground
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    // Show banner + play sound even in foreground
    completionHandler([.banner, .sound])
  }

  // Called when the user taps or interacts with the notification
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    // later: inspect `response.actionIdentifier` to handle “Snooze” or “Mark Done”
    completionHandler()
  }
}
