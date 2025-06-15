import SwiftUI

/// Root view showing reminders and people tabs.
struct ContentView: View {
    var body: some View {
        TabView {
            RemindersListView()
                .tabItem {
                    Label("Reminders", systemImage: "list.bullet")
                }
            PeopleView()
                .tabItem {
                    Label("People", systemImage: "person.2")
                }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext,
                     PersistenceController.shared.container.viewContext)
}
