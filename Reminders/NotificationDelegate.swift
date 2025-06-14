import Foundation
import UserNotifications
import CoreData

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    // Core Data context
    let viewContext = PersistenceController.shared.container.viewContext

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        registerCategories()
    }

    private func registerCategories() {
        let snooze = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: "Snooze 10 min",
            options: []
        )
        let markDone = UNNotificationAction(
            identifier: "MARK_DONE_ACTION",
            title: "Mark Done",
            options: [.destructive]
        )
        let category = UNNotificationCategory(
            identifier: "REMINDER_CATEGORY",
            actions: [snooze, markDone],
            intentIdentifiers: [],
            options: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    // Show banner + sound even in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completion: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completion([.banner, .sound])
    }

    // Handle Snooze and Done actions
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completion: @escaping () -> Void
    ) {
        let idString = response.notification.request.identifier
        guard let uuid = UUID(uuidString: idString) else {
            completion()
            return
        }

        // Fetch the Reminder
        let fetch: NSFetchRequest<Reminder> = Reminder.fetchRequest()
        fetch.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)

        if let rem = (try? viewContext.fetch(fetch))?.first {
            switch response.actionIdentifier {
            case "SNOOZE_ACTION":
              // bump by 10 minutes
              rem.dateTime = Date().addingTimeInterval(600)
              rem.snoozeCount += 1

              // ← new history entry
              let record = SnoozeRecord(context: viewContext)
              record.id        = UUID()
              record.timestamp = Date()
              record.reminder  = rem

              try? viewContext.save()
              NotificationScheduler.cancel(rem)
              NotificationScheduler.schedule(rem)


            case "MARK_DONE_ACTION":
                rem.isActive = false
                try? viewContext.save()
                NotificationScheduler.cancel(rem)

            default:
                break
            }
        }

        completion()
    }

}
