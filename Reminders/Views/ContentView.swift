import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Reminder.dateTime, ascending: true)],
        animation: .default)
    private var reminders: FetchedResults<Reminder>

    @State private var showingAdd = false

    var body: some View {
        NavigationView {
            List {
                ForEach(reminders) { rem in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(rem.title ?? "No Title")
                                .font(.headline)
                            if let note = rem.note, !note.isEmpty {
                                Text(note)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        if let date = rem.dateTime {
                            Text(date, style: .time)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteReminders)
            }
            .navigationTitle("Reminders")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAdd.toggle() }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddReminderView()
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }

    private func deleteReminders(offsets: IndexSet) {
        offsets.map { reminders[$0] }.forEach(viewContext.delete)
        saveContext()
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving context:", error)
        }
    }
}
