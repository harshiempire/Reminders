import SwiftUI
import CoreData

/// Lists saved people.
struct PeopleView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Person.name, ascending: true)],
        animation: .default
    )
    private var people: FetchedResults<Person>

    @State private var showingAdd = false

    var body: some View {
        NavigationView {
            List {
                ForEach(people) { person in
                    NavigationLink(destination: PersonDetailView(person: person)) {
                        Text(person.name ?? "Untitled")
                    }
                }
                .onDelete(perform: deletePeople)
            }
            .navigationTitle("People")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAdd.toggle() }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddPersonView()
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }

    private func deletePeople(at offsets: IndexSet) {
        offsets.map { people[$0] }.forEach(viewContext.delete)
        try? viewContext.save()
    }
}

#Preview {
    PeopleView()
        .environment(\.managedObjectContext,
                     PersistenceController.shared.container.viewContext)
}
