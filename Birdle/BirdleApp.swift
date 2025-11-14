import SwiftUI

@main
struct BirdleApp: App {

    init() {
        // URLSession reuse for images between runs
        URLCache.shared = URLCache(
            memoryCapacity: 50 * 1024 * 1024,   // should b 50 MB RAM
            diskCapacity: 200 * 1024 * 1024,    // and 200 MB disk
            diskPath: "birdle-cache"
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()   // main menu with all the nav stuff (start puzzle takes us to puzzle view for example)
        }
    }
}
