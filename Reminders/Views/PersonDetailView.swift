import SwiftUI

/// Displays information about a person.
struct PersonDetailView: View {
    @ObservedObject var person: Person

    var body: some View {
        Form {
            Text(person.name ?? "")
                .font(.headline)
            if let last = person.lastContactedAt {
                Text("Last contacted: \(last.formatted())")
            }
        }
        .navigationTitle("Person")
    }
}

#Preview {
    let context = PersistenceController.shared.container.viewContext
    let p = Person(context: context)
    p.name = "Sample"
    return PersonDetailView(person: p)
}
