import SwiftUI
import CDPCore

/// Manage EVM spend permissions.
struct SpendPermissionsView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = SpendPermissionsViewModel()

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

                smartAccountSection
                listSection
                createSection
            }
            .padding()
        }
        .task {
            viewModel.client = appState.client
        }
    }

    // MARK: - Smart Account picker

    private var smartAccountSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "Smart Account")

            if smartAddresses.isEmpty {
                Text("No smart accounts. Create one in the Accounts tab.")
                    .foregroundStyle(.secondary)
                    .font(.callout)
            } else {
                Picker("Smart Account", selection: $viewModel.selectedSmartAccount) {
                    Text("Select...").tag("")
                    ForEach(smartAddresses, id: \.self) { addr in
                        Text(addr.truncatedAddress).tag(addr)
                    }
                }
                .pickerStyle(.menu)

                Picker("Network", selection: $viewModel.network) {
                    Text("Base Sepolia").tag(SendEvmTransactionNetwork.baseSepolia)
                    Text("Base").tag(SendEvmTransactionNetwork.base)
                    Text("Ethereum Sepolia").tag(SendEvmTransactionNetwork.ethereumSepolia)
                    Text("Ethereum").tag(SendEvmTransactionNetwork.ethereum)
                }
                .pickerStyle(.menu)
            }
        }
        .cardStyle()
    }

    // MARK: - List

    private var listSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Active Permissions")

            LoadingButton(title: "Refresh", isLoading: viewModel.isLoading) {
                await viewModel.listPermissions()
            }
            .disabled(viewModel.selectedSmartAccount.isEmpty)

            if viewModel.permissions.isEmpty {
                Text("No spend permissions")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.permissions, id: \.permissionHash) { perm in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Spender:")
                                .font(.caption.bold())
                            AddressLabel(address: perm.permission.spender)
                        }
                        Text("Token: \(perm.permission.token.truncatedAddress)")
                            .font(.caption)
                        Text("Allowance: \(perm.permission.allowance)")
                            .font(.caption)
                        Text("Period: \(perm.permission.period)s")
                            .font(.caption)
                        Text("Network: \(perm.network)")
                            .font(.caption)
                        if perm.revoked {
                            Text("Status: revoked")
                                .font(.caption.bold())
                                .foregroundStyle(.red)
                        } else {
                            Button("Revoke") {
                                Task { await viewModel.revokePermission(perm) }
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                            .controlSize(.small)
                        }
                    }
                    .padding(.vertical, 4)

                    Divider()
                }
            }
        }
        .cardStyle()
    }

    // MARK: - Create

    private var createSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Create Permission")

            TextField("Spender address (0x...)", text: $viewModel.spender)
                .textFieldStyle(.roundedBorder)
                .font(.system(.body, design: .monospaced))

            TextField("Token (\"eth\", \"usdc\" or 0x contract address)", text: $viewModel.token)
                .textFieldStyle(.roundedBorder)
                .font(.system(.body, design: .monospaced))

            TextField("Allowance (base units)", text: $viewModel.allowance)
                .textFieldStyle(.roundedBorder)

            Stepper("Period: \(viewModel.periodDays) days", value: $viewModel.periodDays, in: 1...365)

            DatePicker("End Date", selection: $viewModel.endDate, in: Date()..., displayedComponents: .date)

            LoadingButton(title: "Create Permission", isLoading: viewModel.isLoading) {
                await viewModel.createPermission()
            }
            .disabled(viewModel.selectedSmartAccount.isEmpty || viewModel.spender.isEmpty || viewModel.token.isEmpty || viewModel.allowance.isEmpty)
        }
        .cardStyle()
    }
}
