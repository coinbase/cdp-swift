import SwiftUI
import CDPCore

/// EVM operations: sign messages/hashes/transactions, send transactions, user operations.
struct EvmOperationsView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = EvmOperationsViewModel()

    private var evmAddresses: [String] {
        appState.user?.evmAccountObjects?.map(\.address) ?? []
    }

    private var smartAddresses: [String] {
        appState.user?.evmSmartAccountObjects?.map(\.address) ?? []
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
                signHashSection
                signTransactionSection
                sendTransactionSection
                userOperationSection
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
            SectionHeader(title: "EVM Account")

            if evmAddresses.isEmpty {
                Text("No EVM accounts. Create one in the Accounts tab.")
                    .foregroundStyle(.secondary)
                    .font(.callout)
            } else {
                Picker("EOA Account", selection: $viewModel.selectedAddress) {
                    Text("Select...").tag("")
                    ForEach(evmAddresses, id: \.self) { addr in
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

    // MARK: - Sign Hash

    private var signHashSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Sign Hash")

            TextField("0x...", text: $viewModel.hash)
                .textFieldStyle(.roundedBorder)
                .font(.system(.body, design: .monospaced))

            LoadingButton(title: "Sign Hash", isLoading: viewModel.isLoading) {
                await viewModel.signHash()
            }
            .disabled(viewModel.selectedAddress.isEmpty)
        }
        .cardStyle()
    }

    // MARK: - Sign Transaction

    private var signTransactionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Sign Transaction")

            TextField("To address (0x...)", text: $viewModel.toAddress)
                .textFieldStyle(.roundedBorder)
                .font(.system(.body, design: .monospaced))

            TextField("Value (wei)", text: $viewModel.value)
                .textFieldStyle(.roundedBorder)

            LoadingButton(title: "Sign Transaction", isLoading: viewModel.isLoading) {
                await viewModel.signTransaction()
            }
            .disabled(viewModel.selectedAddress.isEmpty)
        }
        .cardStyle()
    }

    // MARK: - Send Transaction

    private var sendTransactionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Send Transaction")

            Picker("Network", selection: $viewModel.network) {
                Text("Base Sepolia").tag(SendEvmTransactionNetwork.baseSepolia)
                Text("Base").tag(SendEvmTransactionNetwork.base)
                Text("Ethereum Sepolia").tag(SendEvmTransactionNetwork.ethereumSepolia)
                Text("Ethereum").tag(SendEvmTransactionNetwork.ethereum)
            }
            .pickerStyle(.menu)

            LoadingButton(title: "Send Transaction", isLoading: viewModel.isLoading) {
                await viewModel.sendTransaction()
            }
            .disabled(viewModel.selectedAddress.isEmpty)
        }
        .cardStyle()
    }

    // MARK: - User Operation

    private var userOperationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Send User Operation", subtitle: "Smart Account")

            if smartAddresses.isEmpty {
                Text("No smart accounts. Create one in the Accounts tab.")
                    .foregroundStyle(.secondary)
                    .font(.callout)
            } else {
                Picker("Smart Account", selection: $viewModel.smartAccountAddress) {
                    Text("Select...").tag("")
                    ForEach(smartAddresses, id: \.self) { addr in
                        Text(addr.truncatedAddress).tag(addr)
                    }
                }
                .pickerStyle(.menu)

                TextField("Call to (0x...)", text: $viewModel.callTo)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))

                TextField("Call value (wei)", text: $viewModel.callValue)
                    .textFieldStyle(.roundedBorder)

                TextField("Call data (0x...)", text: $viewModel.callData)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))

                Picker("Network", selection: $viewModel.userOpNetwork) {
                    Text("Base Sepolia").tag(EvmUserOperationNetwork.baseSepolia)
                    Text("Base").tag(EvmUserOperationNetwork.base)
                    Text("Ethereum Sepolia").tag(EvmUserOperationNetwork.ethereumSepolia)
                }
                .pickerStyle(.menu)

                Toggle("Use CDP Paymaster", isOn: $viewModel.useCdpPaymaster)

                LoadingButton(title: "Send User Operation", isLoading: viewModel.isLoading) {
                    await viewModel.sendUserOperation()
                }
                .disabled(viewModel.smartAccountAddress.isEmpty)

                LoadingButton(title: "Check Status", isLoading: viewModel.isLoading) {
                    await viewModel.pollUserOperation()
                }
                .disabled(viewModel.lastUserOpHash == nil)
            }
        }
        .cardStyle()
    }
}
