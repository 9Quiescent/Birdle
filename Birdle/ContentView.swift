import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Play") {
                    NavigationLink("Start Puzzle") { PuzzleView() }
                    NavigationLink("Help") { HelpView() }
                }
                Section("My Birdle") {
                    NavigationLink("History") { HistoryView() }
                    NavigationLink("Upload Image") { UploadView() }
                }
                Section("About") {
                    NavigationLink("About / Copyright") { AboutView() }
                }
            }
            .navigationTitle("Birdle")
        }
    }
}
