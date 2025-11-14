import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    // Preview store with sample Attempt rows for SwiftUI previews
    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        // Seed a few demo attempts
        let samples: [(name: String, imageID: String, success: Bool, tries: Int16, seconds: Double)] = [
            ("Silver Gull",        "0008", true,  2, 38),
            ("Australian Magpie",  "0002", true,  1, 24),
            ("Galah",              "0006", false, 5, 75)
        ]

        for s in samples {
            let a = Attempt(context: viewContext)
            a.date = Date()
            a.name = s.name
            a.imageID = s.imageID
            a.photographer = "Preview Photographer"
            a.license = "Creative Commons (preview)"
            a.birdLink = "https://example.com/\(s.name.replacingOccurrences(of: " ", with: "_"))"
            a.success = s.success
            a.tries = s.tries
            a.seconds = s.seconds
            // a.photoData can stay nil for previews... for now lol. We'll see if I have enough time.
        }

        do { try viewContext.save() }
        catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        // MUST match the .xcdatamodeld name
        container = NSPersistentContainer(name: "Birdle")

        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        // Merge background saves into main context
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
