import SwiftUI
import UserNotifications

@main
struct RemindersApp: App {
  // 1️⃣ Persistence
  let persistenceController = PersistenceController.shared
  // 2️⃣ Notification delegate
  let notificationDelegate = NotificationDelegate()

  init() {
    // 3️⃣ Ask for permission
    UNUserNotificationCenter
      .current()
      .requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if let err = error { print("Notif auth error:", err) }
      }
    // Note: our NotificationDelegate’s init() has already set
    // UNUserNotificationCenter.current().delegate = notificationDelegate
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(\.managedObjectContext,
                     persistenceController.container.viewContext)
    }
  }
}
