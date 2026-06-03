import SwiftUI
#if os(macOS)
import AppKit
#endif

@main
struct CDPCoreDemoApp: App {
    @StateObject private var appState = AppState()

    init() {
        #if os(macOS)
        // SPM executables lack a .app bundle, so macOS won't treat them
        // as regular GUI apps. This forces proper foreground app behavior
        // (dock icon, keyboard focus, window management).
        NSApplication.shared.setActivationPolicy(.regular)
        NSApplication.shared.activate(ignoringOtherApps: true)
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .task {
                    await appState.initializeSDK()
                }
                .onOpenURL { url in
                    Task {
                        await appState.handleOpenURL(url)
                    }
                }
        }
    }
}
