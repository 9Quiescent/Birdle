import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {

                // Title with info icon
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                    Text("About Birdle")
                        .font(.title.bold())
                }

                // Area for my student ID and usage context
                Text("Student: Dennis Kalongonda\nStudentID: Kaldt001\nPurpose: Educational use only.")

                // License note
                Text("All images and data used under the licenses specified by the API or uploaders.")
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}
