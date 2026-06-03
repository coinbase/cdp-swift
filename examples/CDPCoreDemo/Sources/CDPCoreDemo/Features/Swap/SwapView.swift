import SwiftUI
import CDPCore

/// Token swap operations: get price and execute swap.
struct SwapView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = SwapViewModel()

    private var evmAddresses: [String] {
        appState.user?.evmAccountObjects?.map(\.address) ?? []
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

                swapFormSection
            }
            .padding()
        }
        .task {
            viewModel.client = appState.client
        }
    }

    private var swapFormSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Swap Tokens", subtitle: "EVM token swaps via CDP")

            Picker("Account", selection: $viewModel.takerAddress) {
                Text("Select account...").tag("")
                ForEach(evmAddresses, id: \.self) { addr in
                    Text(addr.truncatedAddress).tag(addr)
                }
            }
            .pickerStyle(.menu)

            TextField("From token (address or symbol)", text: $viewModel.fromToken)
                .textFieldStyle(.roundedBorder)

            TextField("To token (address or symbol)", text: $viewModel.toToken)
                .textFieldStyle(.roundedBorder)

            TextField("Amount", text: $viewModel.fromAmount)
                .textFieldStyle(.roundedBorder)
                #if os(iOS)
                .keyboardType(.decimalPad)
                #endif

            Picker("Network", selection: $viewModel.network) {
                Text("Base").tag(SwapNetwork.base)
                Text("Ethereum").tag(SwapNetwork.ethereum)
                Text("Arbitrum").tag(SwapNetwork.arbitrum)
                Text("Optimism").tag(SwapNetwork.optimism)
                Text("Polygon").tag(SwapNetwork.polygon)
            }
            .pickerStyle(.menu)

            TextField("Slippage (bps, e.g. 100 = 1%)", text: $viewModel.slippageBps)
                .textFieldStyle(.roundedBorder)
                #if os(iOS)
                .keyboardType(.numberPad)
                #endif

            HStack(spacing: 12) {
                LoadingButton(title: "Get Price", isLoading: viewModel.isLoading) {
                    await viewModel.getSwapPrice()
                }
                .disabled(viewModel.fromToken.isEmpty || viewModel.toToken.isEmpty)

                LoadingButton(title: "Execute Swap", isLoading: viewModel.isLoading) {
                    await viewModel.executeSwap()
                }
                .disabled(viewModel.fromToken.isEmpty || viewModel.toToken.isEmpty || viewModel.fromAmount.isEmpty)
            }
        }
        .cardStyle()
    }
}
