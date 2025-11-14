import SwiftUI

struct SplashView: View {
    @State private var goHome = false

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: 16) {
                Image("BirdleLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                Text("Birdle")
                    .font(.largeTitle).bold()
            }
        }
        .onAppear {
            // basically do an initial “load”, then go to the app's content page on boot.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                goHome = true
            }
        }
        .fullScreenCover(isPresented: $goHome) {
            ContentView()   // your main menu
        }
    }
}
