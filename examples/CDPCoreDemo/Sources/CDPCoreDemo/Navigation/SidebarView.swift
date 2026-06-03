import SwiftUI

/// macOS sidebar navigation listing all sections.
struct SidebarView: View {
    @Binding var selection: TabSection?
    @EnvironmentObject var appState: AppState

    var body: some View {
        List(visibleSections, selection: $selection) { section in
            Label(section.rawValue, systemImage: section.icon)
                .tag(section)
        }
        .navigationTitle("CDP Wallets")
    }

    private var visibleSections: [TabSection] {
        TabSection.allCases.filter { section in
            !section.requiresAuth || appState.isAuthenticated
        }
    }
}
