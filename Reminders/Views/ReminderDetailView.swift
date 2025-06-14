import SwiftUI
import CoreData

private let dateTimeFormatter: DateFormatter = {
  let f = DateFormatter()
  f.dateStyle = .medium; f.timeStyle = .short
  return f
}()

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
        Text("Next: \(reminder.dateTime!, formatter: dateTimeFormatter)")
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
  }
}
import SwiftUI

/// Simple read-only display of a reminder's information.
struct ReminderDetailView: View {
    @ObservedObject var reminder: Reminder

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(reminder.title ?? "No Title")
                .font(.title2)
            if let note = reminder.note, !note.isEmpty {
                Text(note)
            }
            if let date = reminder.dateTime {
                Text(date, style: .date)
                Text(date, style: .time)
            }
            if let rule = reminder.recurrenceRule {
                Text("Repeats: \(Recurrence.from(rule: rule).rawValue)")
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Reminder Details")
    }
}
