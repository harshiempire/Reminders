import SwiftUI
import CoreData

private let dateTimeFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateStyle = .medium
    f.timeStyle = .short
    return f
}()

/// Detailed view showing info and snooze history for a reminder.
struct ReminderDetailView: View {
    @ObservedObject var reminder: Reminder
    @Environment(\.managedObjectContext) private var viewContext

    private var snoozeHistory: [SnoozeRecord] {
        (reminder.snoozeRecords as? Set<SnoozeRecord> ?? [])
            .sorted { ($0.timestamp ?? .distantPast) > ($1.timestamp ?? .distantPast) }
    }

    var body: some View {
        Form {
            Section("Info") {
                Text(reminder.title ?? "")
                    .font(.headline)
                if let note = reminder.note {
                    Text(note).font(.body)
                }
                if let next = reminder.dateTime {
                    Text("Next: \(next, formatter: dateTimeFormatter)")
                }
                if let rule = reminder.recurrenceRule {
                    Text("Repeats: \(rule)")
                }
            }

            Section("Snooze History (\(reminder.snoozeCount))") {
                if snoozeHistory.isEmpty {
                    Text("No snoozes yet")
                } else {
                    ForEach(snoozeHistory, id: \.id) { rec in
                        if let timestamp = rec.timestamp {
                            Text(timestamp, formatter: dateTimeFormatter)
                        }
                    }
                }
            }

            Section("Actions") {
                Button("Snooze 10 min") {
                    reminder.dateTime = Date().addingTimeInterval(600)
                    reminder.snoozeCount += 1
                    let record = SnoozeRecord(context: viewContext)
                    record.id = UUID()
                    record.timestamp = Date()
                    record.reminder = reminder
                    try? viewContext.save()
                    NotificationScheduler.cancel(reminder)
                    NotificationScheduler.schedule(reminder)
                }
                Button("Mark Done", role: .destructive) {
                    reminder.isActive = false
                    try? viewContext.save()
                    NotificationScheduler.cancel(reminder)
                }
            }
        }
        .navigationTitle("Details")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink("Edit") { EditReminderView(reminder: reminder) }
            }
        }
    }
}
