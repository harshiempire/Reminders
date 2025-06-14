import CoreData

/// Simple entity representing a single snooze action for a reminder.
class SnoozeRecord: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var timestamp: Date?
    @NSManaged var reminder: Reminder?
}
