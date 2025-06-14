import CoreData
import UserNotifications

struct PersistenceController {
  static let shared = PersistenceController()

  let container: NSPersistentContainer

  init(inMemory: Bool = false) {
    container = NSPersistentContainer(name: "ReminderApp")
    if inMemory {
      container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
    }
    var loadError: NSError?
    container.loadPersistentStores { description, error in
      if let error = error as NSError? {
        loadError = error
      }
    }
    if let error = loadError {
      fatalError("Unresolved Core Data error: \(error), \(error.userInfo)")
    }
    // ▶️ On startup, schedule every active reminder:
    let ctx: NSManagedObjectContext = container.viewContext
    let req: NSFetchRequest<Reminder> = Reminder.fetchRequest()
    req.predicate = NSPredicate(format: "isActive == YES")
    
    if let items = try? ctx.fetch(req) {
        items.forEach { NotificationScheduler.schedule($0) }

    }
    container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
  }
}
