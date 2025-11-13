import SwiftUI

struct UploadView: View {
    var body: some View {
        Form {
            Section("Photo") {
                Button("Pick an image") { /* obv set up image picker */ }
            }
            Section("Details") {
                Text("Photographer: (enter later)")
                Text("License: (enter later)")
                Text("Bird name: (enter later)")
                Text("Link: (enter later)")
            }
        }
        .navigationTitle("Upload")
    }
}
