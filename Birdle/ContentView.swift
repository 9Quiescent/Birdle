import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Birdle")
                    .font(.largeTitle.bold())
                Text("Project is running on the simulator.")
                Button("Add dummy item") {
                    // Test sim
                }
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}
