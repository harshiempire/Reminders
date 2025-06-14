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
    _ = notificationDelegate
      UNUserNotificationCenter.current()
             .requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                 if let error = error {
                     print("Notification permission error: \(error.localizedDescription)")
                 } else {
                     print("Notification permission granted: \(granted)")
                 }
             }
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(\.managedObjectContext,
                     persistenceController.container.viewContext)
    }
  }
}
