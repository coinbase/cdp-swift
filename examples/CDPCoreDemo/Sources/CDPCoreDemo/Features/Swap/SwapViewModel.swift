import Foundation
import CDPCore

@MainActor
final class SwapViewModel: ObservableObject {
    var client: WalletsClient?

    @Published var isLoading = false
    @Published var error: String?
    @Published var result: String?

    @Published var takerAddress = ""
    @Published var fromToken = ""
    @Published var toToken = ""
    @Published var fromAmount = ""
    @Published var slippageBps = "100" // 100 bps = 1%
    @Published var network: SwapNetwork = .base

    func getSwapPrice() async {
        guard let client else { return }
        guard !fromAmount.isEmpty else {
            error = "Enter a from amount"
            return
        }
        isLoading = true
        error = nil

        do {
            let options = GetSwapPriceOptions(
                fromToken: fromToken,
                toToken: toToken,
                fromAmount: fromAmount,
                account: takerAddress.isEmpty ? nil : takerAddress,
                network: network,
                slippageBps: Int(slippageBps)
            )
            let price = try await client.getSwapPrice(options)
            if price.liquidityAvailable {
                let toAmount = price.toAmount ?? "?"
                result = "Quote: \(fromAmount) → \(toAmount) (min \(price.minToAmount ?? "?"))"
            } else {
                result = "No liquidity for this pair"
            }
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func executeSwap() async {
        guard let client else { return }
        guard !fromAmount.isEmpty else {
            error = "Enter a from amount"
            return
        }
        isLoading = true
        error = nil

        do {
            let options = ExecuteSwapOptions(
                fromToken: fromToken,
                toToken: toToken,
                fromAmount: fromAmount,
                account: takerAddress.isEmpty ? nil : takerAddress,
                network: network,
                slippageBps: Int(slippageBps)
            )
            let res = try await client.executeSwap(options)
            switch res {
            case .eoaResult(let transactionHash):
                result = "Swap TX: \(transactionHash)"
            case .smartAccountResult(let userOpHash):
                result = "Swap UserOp: \(userOpHash)"
            }
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func dismissError() {
        error = nil
    }
}
