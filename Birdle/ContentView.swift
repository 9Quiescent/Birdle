import SwiftUI

// Reusable black background, white text button style
// Does a simple pressed-state darken, rounded rectangle clip.
struct MonochromeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(configuration.isPressed ? .black.opacity(0.85) : .black)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct ContentView: View {
    // Two equal columns with a small gutter
    private let columns = [GridItem(.flexible(), spacing: 12),
                           GridItem(.flexible(), spacing: 12)]

    var body: some View {
        NavigationStack {
            // Scroll so the grid breathes on small devices
            ScrollView {
                VStack(spacing: 20) {

                    // Logo + title + student id
                    VStack(spacing: 8) {
                        Image("BirdleLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .shadow(radius: 2)
                        Text("It's wordle... but BIRDS (kinda)!")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 12)

                    // Main navigation actions arranged in a 2-column grid
                    LazyVGrid(columns: columns, spacing: 12) {

                        // Play
                        NavigationLink {
                            PuzzleView()
                        } label: {
                            Label("Start Today's Puzzle", systemImage: "play.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(MonochromeButtonStyle())

                        // Help
                        NavigationLink {
                            HelpView()
                        } label: {
                            Label("Help", systemImage: "questionmark.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(MonochromeButtonStyle())

                        // History
                        NavigationLink {
                            HistoryView()
                        } label: {
                            Label("Your Birdle History", systemImage: "clock.arrow.circlepath")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(MonochromeButtonStyle())

                        // Upload
                        NavigationLink {
                            UploadView()
                        } label: {
                            Label("Upload A Birdle", systemImage: "square.and.arrow.up.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(MonochromeButtonStyle())

                        // About
                        NavigationLink {
                            AboutView()
                        } label: {
                            Label("About", systemImage: "info.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(MonochromeButtonStyle())
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 24)
            }
            .navigationTitle("Birdle")
            // Quick-access info button in the nav bar
            .toolbar {
                NavigationLink {
                    AboutView()
                } label: {
                    Image(systemName: "info.circle")
                }
            }
        }
    }
}
