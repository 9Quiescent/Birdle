import SwiftUI

struct HelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {

                // Title with question icon
                HStack(spacing: 8) {
                    Image(systemName: "questionmark.circle.fill")
                    Text("How to play")
                        .font(.title.bold())
                }

                // Core loop description
                Text("Guess the bird. You get up to 6 images. Each wrong guess reveals the next image. A correct guess shows the final image and details.")

                // Short helpful tips
                Text("Tips")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 6) {
                    Text("• Focus on standout features like beak shape, leg length, plumage patterns and silhouette.")
                    Text("• The image becomes less obscured after each incorrect attempt, use that to your advantage.")
                    Text("• You only get one run of attempts per day, choose carefully.")
                    Text("• Use exact common names. Autocomplete helps once you start typing.")
                }
                .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("Help")
        .navigationBarTitleDisplayMode(.inline)
    }
}
