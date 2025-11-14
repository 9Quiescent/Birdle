import SwiftUI
import CoreData

struct PuzzleView: View {
    @Environment(\.managedObjectContext) private var context

    @State private var bird: Birdle?
    @State private var names: [String] = []
    @State private var guess = ""
    @State private var filtered: [String] = []
    @State private var clueIndex = 0      // 0...4 during play; 5 on finish. 5 is no distortion.
    @State private var tries = 0
    @State private var startedAt = Date()
    @State private var finished = false
    @State private var toast: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let bird {
                    RemoteImage(url: bird.imageURL(for: finished ? 5 : clueIndex))
                        .frame(maxHeight: 320)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(radius: 2)

                    if !finished {
                        VStack(alignment: .leading, spacing: 10) {
                            TextField("Type the bird’s name", text: $guess)
                                .textInputAutocapitalization(.words)
                                .autocorrectionDisabled()
                                .padding(12)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                                .onChange(of: guess) { _, newVal in
                                    filtered = autocomplete(for: newVal)
                                }

                            if !filtered.isEmpty {
                                ForEach(filtered.prefix(5), id: \.self) { name in
                                    Button {
                                        guess = name
                                        filtered = []
                                    } label: {
                                        HStack {
                                            Image(systemName: "sparkle.magnifyingglass")
                                            Text(name)
                                            Spacer()
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.vertical, 4)
                                }
                            }

                            Button("Submit guess") { submit() }
                                .buttonStyle(.borderedProminent)

                            Text("Attempt \(tries) of 5")
                                .font(.footnote).foregroundStyle(.secondary)
                        }
                    } else {
                        successBlock(bird)
                    }
                } else {
                    ProgressView("Loading today's bird of the day…")
                }
            }
            .padding()
        }
        .navigationTitle("Puzzle")
        .task { await initialLoad() }
        .alert("Birdle", isPresented: .constant(toast != nil)) {
            Button("OK") { toast = nil }
        } message: {
            Text(toast ?? "")
        }
    }

    // MARK: - Flow

    private func submit() {
        guard let bird else { return }
        let norm = normalize(guess)
        let target = normalize(bird.name)

        var justSucceeded = false
        tries += 1

        if norm == target {
            finished = true
            justSucceeded = true
            toast = "You did it! That is indeed a \(bird.name)."
        } else if tries >= 5 {
            finished = true
            clueIndex = 5
            toast = "Unlucky! The bird was \(bird.name)."
        } else {
            clueIndex = min(clueIndex + 1, 4)
            toast = "Not quite, try again."
        }

        guess = ""

        if finished {
            let dur = Date().timeIntervalSince(startedAt)
            // not caching the final UIImage for now, so nil for the image preview for now.
            HistoryStore.saveAttempt(
                context: context,
                bird: bird,
                tries: tries,
                duration: dur,
                success: justSucceeded,
                finalImage: nil
            )
            markAttempted(imageID: bird.image)
        }
    }

    private func normalize(_ s: String) -> String {
        s.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: .diacriticInsensitive, locale: .current)
    }

    private func autocomplete(for query: String) -> [String] {
        let q = normalize(query)
        guard q.count >= 2 else { return [] }
        return names.filter { normalize($0).contains(q) }.sorted()
    }

    @MainActor
    private func successBlock(_ bird: Birdle) -> some View {
        VStack(spacing: 12) {
            Text(bird.name).font(.title3.bold())
            Link("Learn more", destination: URL(string: bird.bird_link)!)
            Text("Photographer: \(bird.photographer)").font(.footnote)
            Text(bird.license).font(.footnote).foregroundStyle(.secondary)
        }
    }

    private func load() async {
        startedAt = Date()
        do {
            // For debugging a specific puzzle:
            // bird = try await BirdleAPI.shared.fetchByID(1)
            bird = try await BirdleAPI.shared.fetchToday()
            names = try await BirdleAPI.shared.fetchAllNames()
        } catch {
            toast = "Couldn’t load puzzle. Check your connection."
        }
    }

    private func initialLoad() async {
        await load()
        if let b = bird, hasAttempted(imageID: b.image) {
            finished = true
            clueIndex = 5
            toast = "You’ve already attempted today’s bird."
        }
    }
}
