import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("About Birdle")
                    .font(.title.bold())
                Text("Student: Dennis Kalongonda\nPurpose: Educational use only.")
                Text("All images and data used under the licenses specified by the API or uploaders.")
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}
