import SwiftUI
import CDPCore

/// Solana operations: sign messages/transactions, send transactions.
struct SolanaOperationsView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = SolanaOperationsViewModel()

    private var solanaAddresses: [String] {
        appState.user?.solanaAccountObjects?.map(\.address) ?? []
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let error = viewModel.error {
                    ErrorBanner(message: error, onDismiss: viewModel.dismissError)
                }

                if let result = viewModel.result {
                    ResultCard(title: "Result", content: result)
                }

                accountPicker
                signMessageSection
                signTransactionSection
                sendTransactionSection
            }
            .padding()
        }
        .task {
            viewModel.client = appState.client
        }
    }

    // MARK: - Account Picker

    private var accountPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "Solana Account")

            if solanaAddresses.isEmpty {
                Text("No Solana accounts. Create one in the Accounts tab.")
                    .foregroundStyle(.secondary)
                    .font(.callout)
            } else {
                Picker("Account", selection: $viewModel.selectedAddress) {
                    Text("Select...").tag("")
                    ForEach(solanaAddresses, id: \.self) { addr in
                        Text(addr.truncatedAddress).tag(addr)
                    }
                }
                .pickerStyle(.menu)
            }
        }
        .cardStyle()
    }

    // MARK: - Sign Message

    private var signMessageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Sign Message")

            TextField("Message to sign", text: $viewModel.message)
                .textFieldStyle(.roundedBorder)

            LoadingButton(title: "Sign Message", isLoading: viewModel.isLoading) {
                await viewModel.signMessage()
            }
            .disabled(viewModel.selectedAddress.isEmpty)
        }
        .cardStyle()
    }

    // MARK: - Sign Transaction

    private var signTransactionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Sign Transaction")

            TextField("Base64-encoded transaction", text: $viewModel.transaction, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...6)
                .font(.system(.caption, design: .monospaced))

            LoadingButton(title: "Sign Transaction", isLoading: viewModel.isLoading) {
                await viewModel.signTransaction()
            }
            .disabled(viewModel.selectedAddress.isEmpty || viewModel.transaction.isEmpty)
        }
        .cardStyle()
    }

    // MARK: - Send Transaction

    private var sendTransactionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Send Transaction")

            Picker("Network", selection: $viewModel.network) {
                Text("Devnet").tag(SendSolanaTransactionNetwork.solanaDevnet)
                Text("Mainnet").tag(SendSolanaTransactionNetwork.solanaMainnet)
            }
            .pickerStyle(.segmented)

            Toggle("Use CDP Sponsor", isOn: $viewModel.useCdpSponsor)

            LoadingButton(title: "Send Transaction", isLoading: viewModel.isLoading) {
                await viewModel.sendTransaction()
            }
            .disabled(viewModel.selectedAddress.isEmpty || viewModel.transaction.isEmpty)
        }
        .cardStyle()
    }
}
