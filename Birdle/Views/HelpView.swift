import SwiftUI

struct HelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("How to play")
                    .font(.title.bold())
                Text("Guess the bird. You get up to 6 images. Each wrong guess reveals the next image. A correct guess shows the final image and details.")
                Text("Tips")
                    .font(.headline)
                Text("Use exact common names. Autocomplete coming soon.")
            }
            .padding()
        }
        .navigationTitle("Help")
        .navigationBarTitleDisplayMode(.inline)
    }
}
