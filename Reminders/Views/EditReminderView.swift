import SwiftUI
import CoreData

struct EditReminderView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var reminder: Reminder

    @State private var title: String
    @State private var note: String
    @State private var dateTime: Date
    @State private var recurrenceSelection: AddReminderView.Recurrence

    init(reminder: Reminder) {
        self.reminder = reminder
        _title = State(initialValue: reminder.title ?? "")
        _note = State(initialValue: reminder.note ?? "")
        _dateTime = State(initialValue: reminder.dateTime ?? Date())
        let rule = reminder.recurrenceRule
        let initialRecurrence = AddReminderView.Recurrence.allCases.first { $0.rrule == rule } ?? .none
        _recurrenceSelection = State(initialValue: initialRecurrence)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("Title", text: $title)
                    TextField("Note", text: $note)
                }
                Section(header: Text("When")) {
                    DatePicker("Date & Time", selection: $dateTime)
                    Picker("Repeat", selection: $recurrenceSelection) {
                        ForEach(AddReminderView.Recurrence.allCases) { freq in
                            Text(freq.rawValue).tag(freq)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationTitle("Edit Reminder")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveChanges()
                }
                .disabled(title.isEmpty)
            )
        }
    }

    private func saveChanges() {
        reminder.title = title
        reminder.note = note.isEmpty ? nil : note
        reminder.dateTime = dateTime
        reminder.recurrenceRule = recurrenceSelection.rrule

        // Persist and reschedule
        do {
            try viewContext.save()
            NotificationScheduler.cancel(reminder)
            NotificationScheduler.schedule(reminder)
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving edits:", error)
        }
    }
}
