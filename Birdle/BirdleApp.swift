import SwiftUI
import CoreData

@main
struct BirdleApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            SplashView()
        }
    }
}
