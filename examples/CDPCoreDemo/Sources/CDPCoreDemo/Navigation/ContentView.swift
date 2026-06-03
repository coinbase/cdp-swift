import SwiftUI

/// Platform-adaptive root view.
/// Uses TabView on iOS, NavigationSplitView on macOS.
struct ContentView: View {
    @EnvironmentObject var appState: AppState

    #if os(macOS)
    @State private var selection: TabSection? = .auth
    #endif

    var body: some View {
        Group {
            if !appState.isInitialized {
                loadingView
            } else {
                #if os(iOS)
                iOSNavigation
                #else
                macOSNavigation
                #endif
            }
        }
        .onChange(of: appState.isAuthenticated) { isAuth in
            #if os(macOS)
            // Auto-navigate to Accounts when signing in, Auth when signing out
            selection = isAuth ? .accounts : .auth
            #endif
        }
        .onChange(of: appState.isInitialized) { initialized in
            #if os(macOS)
            // On init, if already authenticated, go to Accounts instead of Auth
            if initialized && appState.isAuthenticated {
                selection = .accounts
            }
            #endif
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Initializing SDK...")
                .foregroundStyle(.secondary)
            if let error = appState.error {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.caption)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - iOS

    #if os(iOS)
    private var iOSNavigation: some View {
        TabView {
            ForEach(visibleSections) { section in
                NavigationStack {
                    section.destinationView
                        .navigationTitle(section.rawValue)
                }
                .tabItem {
                    Label(section.rawValue, systemImage: section.icon)
                }
                .tag(section)
            }
        }
    }
    #endif

    // MARK: - macOS

    #if os(macOS)
    private var macOSNavigation: some View {
        NavigationSplitView {
            SidebarView(selection: $selection)
        } detail: {
            if let section = selection {
                section.destinationView
                    .navigationTitle(section.rawValue)
            } else {
                Text("Select a section")
                    .foregroundStyle(.secondary)
            }
        }
    }
    #endif

    // MARK: - Helpers

    private var visibleSections: [TabSection] {
        TabSection.allCases.filter { section in
            !section.requiresAuth || appState.isAuthenticated
        }
    }
}

// MARK: - Destination Mapping

extension TabSection {
    @ViewBuilder
    var destinationView: some View {
        switch self {
        case .auth: AuthView()
        case .accounts: AccountsView()
        case .evm: EvmOperationsView()
        case .solana: SolanaOperationsView()
        case .swap: SwapView()
        case .mfa: MFAView()
        case .delegation: DelegationView()
        case .permissions: SpendPermissionsView()
        }
    }
}
