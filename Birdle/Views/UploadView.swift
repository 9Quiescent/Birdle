import SwiftUI
import PhotosUI

struct UploadView: View {

    // Monochrome primary button for "Choose A Photo" and "Upload"
    // Slightly tighter radius and a faint stroke to differentiate this screen’s actions.
    struct MonochromeButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.headline)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(configuration.isPressed ? .black.opacity(0.85) : .black)
                .foregroundStyle(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(.white.opacity(0.08), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    @State private var photo: PhotosPickerItem?
    @State private var jpegData: Data?
    @State private var name = ""
    @State private var photographer = ""
    @State private var license = ""
    @State private var photographerLink = ""
    @State private var birdleLink = ""
    @State private var status: String?
    @State private var isUploading = false

    // easy peasy monochrome status banner
    private enum StatusStyle { case info, success, error
        var icon: String {
            switch self { case .info: "info.circle"
                         case .success: "checkmark.seal"
                         case .error: "xmark.octagon" }
        }
        var bg: Color { .gray.opacity(self == .error ? 0.18 : self == .success ? 0.12 : 0.08) }
        var fg: Color { .primary }
        var stroke: Color { .gray.opacity(0.25) }
    }
    @State private var style: StatusStyle = .info

    var body: some View {
        Form {
            Section("Image") {
                if let jpegData, let ui = UIImage(data: jpegData) {
                    Image(uiImage: ui).resizable().scaledToFit().frame(maxHeight: 220)
                }

                // Custom-label initializer so we can style it as a black button
                PhotosPicker(selection: $photo, matching: .images) {
                    Text("Choose A Photo")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
                .buttonStyle(MonochromeButtonStyle()) // visual consistency
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
                Button {
                    Task { await doUpload() }
                } label: {
                    if isUploading { ProgressView() } else { Text("Upload") }
                }
                .buttonStyle(MonochromeButtonStyle())
                .disabled(isUploading || jpegData == nil || name.isEmpty || photographer.isEmpty || license.isEmpty)
            }

            if let status {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: style.icon)
                        .font(.headline)
                    Text(status)
                        .font(.footnote)
                        .textSelection(.enabled)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(style.bg)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(style.stroke))
                )
                .foregroundStyle(style.fg)
            }
        }
        .navigationTitle("Upload A Birdle")
    }

    private func doUpload() async {
        guard let data = jpegData else { status = "Pick an image first."; style = .info; return }
        isUploading = true
        defer { isUploading = false }

        do {
            let outcome = try await BirdleAPI.shared.uploadImageOutcome(
                jpegData: data,
                filename: "bird.jpg",
                name: name,
                photographerName: photographer,
                license: license,
                photographerLink: normalizedURL(photographerLink),
                birdleLink: normalizedURL(birdleLink)
            )
            // immediate server echo
            style = outcome.ok ? .success : .error
            status = outcome.ok ? "Uploaded successfully.\n\(outcome.serverText)"
                                : "Upload failed.\n\(outcome.serverText)"

            if outcome.ok {
                // best-effort verification via list (may still be pending/moderated)
                if let names = try? await BirdleAPI.shared.fetchAllNames() {
                    let normTarget = normalize(name)
                    let found = names.contains { normalize($0) == normTarget }
                    style = found ? .success : .info
                    status = found
                      ? "Uploaded successfully. Confirmed in list: “\(name)”."
                      : "Uploaded successfully. It may take a moment to appear in the list."
                }
                self.jpegData = nil
                name = ""; photographer = ""; license = ""
                photographerLink = ""; birdleLink = ""
            }
        } catch {
            style = .error
            status = "Upload error: \(error.localizedDescription)"
        }
    }

    private func normalizedURL(_ s: String) -> String {
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.isEmpty { return "" }
        if t.lowercased().hasPrefix("http://") || t.lowercased().hasPrefix("https://") { return t }
        return "https://\(t)"
    }

    private func normalize(_ s: String) -> String {
        s.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: .diacriticInsensitive, locale: .current)
    }
}
