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
