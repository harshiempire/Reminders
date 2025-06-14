import SwiftUI
import CoreData
import UserNotifications

// This view demonstrates the modern SwiftUI + Core Data + UserNotifications flow:
//  - When a reminder is saved, Core Data persists it
//  - NotificationScheduler ensures the notification is scheduled
//  - Consistent with edit and snooze flows elsewhere in the app

struct AddReminderView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    @State private var title: String = ""
    @State private var note: String = ""
    @State private var dateTime: Date = Date()
    @State private var recurrenceSelection: Recurrence = .none

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
                        ForEach(Recurrence.allCases) { freq in
                            Text(freq.rawValue).tag(freq)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationTitle("New Reminder")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveReminder()
                }
                .disabled(title.isEmpty)
            )
        }
    }

    private func saveReminder() {
        // 1. Create and save reminder in Core Data
        let rem = Reminder(context: viewContext)
        rem.id = UUID()
        rem.title = title
        rem.note = note.isEmpty ? nil : note
        rem.dateTime = dateTime
        rem.recurrenceRule = recurrenceSelection.rrule
        rem.snoozeCount = 0
        rem.isActive = true

        do {
            try viewContext.save()
            NotificationScheduler.schedule(rem)
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving reminder:", error)
        }
    }

}
