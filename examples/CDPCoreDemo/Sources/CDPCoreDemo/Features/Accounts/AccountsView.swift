import SwiftUI
import CDPCore

/// Displays existing accounts and creation buttons.
struct AccountsView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = AccountsViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let error = viewModel.error {
                    ErrorBanner(message: error, onDismiss: viewModel.dismissError)
                }

                if let result = viewModel.result {
                    ResultCard(title: "Result", content: result)
                }

                // Existing accounts
                if let user = appState.user {
                    existingAccountsSection(user)
                }

                // Create accounts
                createAccountsSection
            }
            .padding()
        }
        .task {
            viewModel.client = appState.client
        }
    }

    // MARK: - Existing Accounts

    private func existingAccountsSection(_ user: User) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Your Accounts")

            if let evmAccounts = user.evmAccountObjects, !evmAccounts.isEmpty {
                ForEach(evmAccounts, id: \.address) { account in
                    HStack {
                        Image(systemName: "cube")
                        VStack(alignment: .leading) {
                            Text("EVM EOA")
                                .font(.caption.bold())
                            AddressLabel(address: account.address)
                        }
                    }
                }
            }

            if let smartAccounts = user.evmSmartAccountObjects, !smartAccounts.isEmpty {
                ForEach(smartAccounts, id: \.address) { account in
                    HStack {
                        Image(systemName: "cube.fill")
                        VStack(alignment: .leading) {
                            Text("EVM Smart Account")
                                .font(.caption.bold())
                            AddressLabel(address: account.address)
                        }
                    }
                }
            }

            if let solanaAccounts = user.solanaAccountObjects, !solanaAccounts.isEmpty {
                ForEach(solanaAccounts, id: \.address) { account in
                    HStack {
                        Image(systemName: "sparkles")
                        VStack(alignment: .leading) {
                            Text("Solana")
                                .font(.caption.bold())
                            AddressLabel(address: account.address)
                        }
                    }
                }
            }

            if (user.evmAccountObjects ?? []).isEmpty &&
               (user.evmSmartAccountObjects ?? []).isEmpty &&
               (user.solanaAccountObjects ?? []).isEmpty {
                Text("No accounts yet")
                    .foregroundStyle(.secondary)
            }
        }
        .cardStyle()
    }

    // MARK: - Create Accounts

    private var createAccountsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Create Account")

            LoadingButton(title: "Create EVM EOA", isLoading: viewModel.isLoading) {
                await viewModel.createEvmEoaAccount()
            }

            LoadingButton(title: "Create EVM Smart Account", isLoading: viewModel.isLoading) {
                await viewModel.createEvmSmartAccount()
            }

            LoadingButton(title: "Create Solana Account", isLoading: viewModel.isLoading) {
                await viewModel.createSolanaAccount()
            }
        }
        .cardStyle()
    }
}
