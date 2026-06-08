import SwiftUI

@main
struct financeApp: App {
    @State private var vm = AppViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(vm)
        }
    }
}
