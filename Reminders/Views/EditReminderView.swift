import SwiftUI
import CoreData

/// View for editing an existing reminder.
struct EditReminderView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    @ObservedObject var reminder: Reminder

    @State private var title: String
    @State private var note: String
    @State private var dateTime: Date
    @State private var recurrenceSelection: Recurrence

    init(reminder: Reminder) {
        _reminder = ObservedObject(wrappedValue: reminder)
        _title = State(initialValue: reminder.title ?? "")
        _note = State(initialValue: reminder.note ?? "")
        _dateTime = State(initialValue: reminder.dateTime ?? Date())
        _recurrenceSelection = State(initialValue: Recurrence.from(rule: reminder.recurrenceRule))
    }

    var body: some View {
        Form {
            Section(header: Text("Details")) {
                TextField("Title", text: $title)
                TextField("Note", text: $note)
            }
            Section(header: Text("When")) {
                DatePicker("Date & Time", selection: $dateTime)
                Picker("Repeat", selection: $recurrenceSelection) {
                    ForEach(Recurrence.allCases) { freq in
                        Text(freq.rawValue).tag(freq)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
        .navigationTitle("Edit Reminder")
        .navigationBarItems(
            trailing: Button("Save") { saveChanges() }
                .disabled(title.isEmpty)
        )
    }

    private func saveChanges() {
        reminder.title = title
        reminder.note = note.isEmpty ? nil : note
        reminder.dateTime = dateTime
        reminder.recurrenceRule = recurrenceSelection.rrule

        do {
            try viewContext.save()
            NotificationScheduler.reschedule(reminder)
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error updating reminder:", error)
        }
    }
}
