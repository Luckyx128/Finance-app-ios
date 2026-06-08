import SwiftUI

struct ContentView: View {
    @Environment(AppViewModel.self) private var vm

    var body: some View {
        ZStack {
            WallpaperView()

            switch vm.appFlow {
            case .splash:
                SplashView {
                    withAnimation(.easeInOut(duration: 0.4)) { vm.appFlow = .onboarding }
                }
                .transition(.opacity)

            case .onboarding:
                OnboardingView {
                    withAnimation(.easeInOut(duration: 0.4)) { vm.appFlow = .auth }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal:   .opacity
                ))

            case .auth:
                AuthView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal:   .opacity
                    ))

            case .setup:
                SetupView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal:   .opacity
                    ))

            case .app:
                MainTabView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal:   .opacity
                    ))
            }
        }
        .preferredColorScheme(.dark)
        .animation(.easeInOut(duration: 0.4), value: vm.appFlow)
    }
}

#Preview {
    ContentView()
        .environment(AppViewModel())
}
