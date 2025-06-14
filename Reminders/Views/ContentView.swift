import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Reminder.dateTime, ascending: true)],
        animation: .default
    )
    private var reminders: FetchedResults<Reminder>

    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Use .glassBackground() if available, otherwise fallback to .ultraThinMaterial
                List {
                    ForEach(reminders) { rem in
                        NavigationLink(destination: ReminderDetailView(reminder: rem)) {
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
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                            .padding(.vertical, 4)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                // snooze 10m:
                                rem.snoozeCount += 1
                                rem.dateTime = Date().addingTimeInterval(600)
                                try? viewContext.save()
                                NotificationScheduler.cancel(rem)
                                NotificationScheduler.schedule(rem)
                            } label: {
                                Label("Snooze", systemImage: "bell.slash")
                            }
                            .tint(.orange)

                            Button(role: .destructive) {
                                NotificationScheduler.cancel(rem)
                                viewContext.delete(rem)
                                try? viewContext.save()
                            } label: {
                                Label("Done", systemImage: "checkmark.circle")
                            }
                        }
                    }
                    .onDelete(perform: deleteReminders)
                }
                .listStyle(.plain)
                .background(.ultraThinMaterial)
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

    private func deleteReminders(at offsets: IndexSet) {
        offsets.map { reminders[$0] }.forEach { rem in
            NotificationScheduler.cancel(rem)
            viewContext.delete(rem)
        }
        saveContext()
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving context:\(error)")
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext,
                     PersistenceController.shared.container.viewContext)
}
