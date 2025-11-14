import SwiftUI
import PhotosUI

struct UploadView: View {
    @State private var photo: PhotosPickerItem?
    @State private var jpegData: Data?
    @State private var name = ""
    @State private var photographer = ""
    @State private var license = ""
    @State private var photographerLink = ""
    @State private var birdleLink = ""
    @State private var status: String?

    var body: some View {
        Form {
            Section("Image") {
                if let jpegData, let ui = UIImage(data: jpegData) {
                    Image(uiImage: ui).resizable().scaledToFit().frame(maxHeight: 220)
                }
                PhotosPicker("Choose Photo", selection: $photo, matching: .images)
                    .onChange(of: photo) { _, item in
                        Task {
                            if let data = try? await item?.loadTransferable(type: Data.self) {
                                // Always make sure that we JPEG-encode to be sure of content-type
                                if let ui = UIImage(data: data),
                                   let jpg = ui.jpegData(compressionQuality: 0.9) {
                                    jpegData = jpg
                                } else {
                                    jpegData = data // hope it's already jpeg
                                }
                            }
                        }
                    }
            }

            Section("Details") {
                TextField("Bird name", text: $name)
                TextField("Photographer name", text: $photographer)
                TextField("License", text: $license)
                TextField("Photographer link (URL)", text: $photographerLink)
                TextField("Bird info link (URL)", text: $birdleLink)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
            }

            Section {
                Button("Upload") { Task { await doUpload() } }
                    .disabled(jpegData == nil || name.isEmpty || photographer.isEmpty || license.isEmpty)
            }

            if let status { Text(status).font(.footnote) }
        }
        .navigationTitle("Upload Image")
    }

    private func doUpload() async {
        guard let jpegData else { status = "Pick an image first."; return }
        do {
            let ok = try await BirdleAPI.shared.uploadImage(
                jpegData: jpegData,
                filename: "bird.jpg",
                name: name,
                photographerName: photographer,
                license: license,
                photographerLink: photographerLink,
                birdleLink: birdleLink
            )
            status = ok ? "Uploaded successfully." : "Upload failed (server response)."
        } catch {
            status = "Upload error: \(error)"
        }
    }
}
