import CoreData

/// Represents a person the user wants to remember.
class Person: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var name: String?
    @NSManaged var lastContactedAt: Date?
    @NSManaged var notes: NSSet?
}
