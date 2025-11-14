import SwiftUI
import CoreData

struct HistoryView: View {
    @Environment(\.managedObjectContext) private var context

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Attempt.date, ascending: false)],
        animation: .default
    ) private var attempts: FetchedResults<Attempt>

    var body: some View {
        List {
            if attempts.isEmpty {
                Section {
                    VStack(spacing: 6) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("No attempts yet")
                            .font(.headline)
                        Text("When you make a new attempt, you'll see it here!")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                }
            } else {
                ForEach(attempts) { a in
                    NavigationLink {
                        AttemptDetail(attempt: a)
                    } label: {
                        HStack(spacing: 12) {
                            // small thumbnail, i'll fix this later
                            if let data = a.photoData, let ui = UIImage(data: data) {
                                Image(uiImage: ui)
                                    .resizable().scaledToFill()
                                    .frame(width: 56, height: 56)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                Image(systemName: "photo")
                                    .frame(width: 56, height: 56)
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text(a.name ?? "Unknown").font(.headline)
                                Text("\(a.success ? "Success" : "Failure") · Tries: \(a.tries) · \(format(a.date))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(a.name ?? "Unknown"), \(a.success ? "success" : "failure"), \(a.tries) tries, \(format(a.date))")
                    }
                }
                .onDelete(perform: delete) // swipe-to-delete
            }
        }
        .navigationTitle("History")
        .toolbar { if !attempts.isEmpty { EditButton() } }
    }

    private func delete(at offsets: IndexSet) {
        offsets.map { attempts[$0] }.forEach(context.delete)
        try? context.save()
    }

    private func format(_ d: Date?) -> String {
        guard let d else { return "-" }
        let f = DateFormatter(); f.dateStyle = .medium
        return f.string(from: d)
    }
}

struct AttemptDetail: View {
    let attempt: Attempt
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let data = attempt.photoData, let ui = UIImage(data: data) {
                    Image(uiImage: ui)
                        .resizable().scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                Text(attempt.name ?? "").font(.title3.bold())
                Text("Tries: \(attempt.tries) • \(attempt.success ? "Success" : "Failure")")
                    .foregroundStyle(.secondary)
                if attempt.seconds > 0 {
                    Text("Time: \(Int(attempt.seconds))s").foregroundStyle(.secondary)
                }
                if let p = attempt.photographer, !p.isEmpty { Text("Photographer: \(p)") }
                if let lic = attempt.license, !lic.isEmpty {
                    Text(lic).font(.footnote).foregroundStyle(.secondary)
                }
                if let link = attempt.birdLink, let url = URL(string: link) {
                    Link("Learn more", destination: url)
                }
            }
            .padding()
        }
        .navigationTitle("Attempt")
    }
}
