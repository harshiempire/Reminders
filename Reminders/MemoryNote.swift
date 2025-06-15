import CoreData

/// Text note associated with a person.
class MemoryNote: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var text: String?
    @NSManaged var timestamp: Date?
    @NSManaged var person: Person?
}
