import SwiftUI
import CDPCore

/// Delegation management: create, view, and revoke delegations.
struct DelegationView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = DelegationViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let error = viewModel.error {
                    ErrorBanner(message: error, onDismiss: viewModel.dismissError)
                }

                if let result = viewModel.result {
                    ResultCard(title: "Result", content: result)
                }

                currentDelegationSection
                createDelegationSection
            }
            .padding()
        }
        .task {
            viewModel.client = appState.client
        }
    }

    private var currentDelegationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Current Delegation")

            LoadingButton(title: "Get Delegation", isLoading: viewModel.isLoading) {
                await viewModel.getDelegation()
            }

            if let info = viewModel.delegationInfo {
                VStack(alignment: .leading, spacing: 4) {
                    Label("Active: \(info.isActive ? "Yes" : "No")", systemImage: info.isActive ? "checkmark.circle" : "xmark.circle")
                    if let expires = info.expiresAt {
                        Label("Expires: \(expires)", systemImage: "clock")
                    }
                }
                .font(.callout)

                if info.isActive {
                    LoadingButton(title: "Revoke Delegation", isLoading: viewModel.isLoading) {
                        await viewModel.revokeDelegation()
                    }
                    .tint(.red)
                }
            }
        }
        .cardStyle()
    }

    private var createDelegationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Create Delegation")

            DatePicker("Expires At", selection: $viewModel.expiresAt, in: Date()..., displayedComponents: [.date, .hourAndMinute])

            LoadingButton(title: "Create Delegation", isLoading: viewModel.isLoading) {
                await viewModel.createDelegation()
            }
        }
        .cardStyle()
    }
}
