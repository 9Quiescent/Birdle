import SwiftUI

struct PuzzleView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Puzzle Area")
                .font(.headline)
            Text("Testing... API and image stuff next I reckon.")
                .foregroundColor(.secondary)
        }
        .padding()
        .navigationTitle("Puzzle")
        .navigationBarTitleDisplayMode(.inline)
    }
}
