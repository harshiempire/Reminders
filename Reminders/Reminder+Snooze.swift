import CoreData

extension Reminder {
    @objc(addSnoozeRecordsObject:)
    @NSManaged public func addToSnoozeRecords(_ value: SnoozeRecord)

    @objc(removeSnoozeRecordsObject:)
    @NSManaged public func removeFromSnoozeRecords(_ value: SnoozeRecord)
}
