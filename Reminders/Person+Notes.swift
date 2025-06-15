import CoreData

extension Person {
    @objc(addNotesObject:)
    @NSManaged public func addToNotes(_ value: MemoryNote)

    @objc(removeNotesObject:)
    @NSManaged public func removeFromNotes(_ value: MemoryNote)
}
