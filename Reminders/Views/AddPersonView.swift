import SwiftUI
import CoreData

/// View for creating a new person entry.
struct AddPersonView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    @State private var name: String = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
            }
            .navigationTitle("New Person")
            .navigationBarItems(
                leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() },
                trailing: Button("Save") { save() }.disabled(name.isEmpty)
            )
        }
    }

    private func save() {
        let person = Person(context: viewContext)
        person.id = UUID()
        person.name = name
        person.lastContactedAt = Date()
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving person:", error)
        }
    }
}

#Preview {
    AddPersonView()
        .environment(\.managedObjectContext,
                     PersistenceController.shared.container.viewContext)
}
