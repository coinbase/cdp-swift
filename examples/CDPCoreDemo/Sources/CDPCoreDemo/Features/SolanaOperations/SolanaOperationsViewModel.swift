import Foundation
import CDPCore

/// Manages Solana signing and sending operations.
@MainActor
final class SolanaOperationsViewModel: ObservableObject {
    var client: WalletsClient?

    @Published var isLoading = false
    @Published var error: String?
    @Published var result: String?

    // Form fields
    @Published var selectedAddress = ""
    @Published var message = "Hello, Solana!"
    @Published var transaction = "" // base64 encoded
    @Published var network: SendSolanaTransactionNetwork = .solanaDevnet
    @Published var useCdpSponsor = false

    // MARK: - Sign Message

    func signMessage() async {
        guard let client, !selectedAddress.isEmpty else {
            error = "Select a Solana account"
            return
        }
        isLoading = true
        error = nil

        do {
            // Convert message to base64 for the SDK
            let messageBase64 = Data(message.utf8).base64EncodedString()
            let res = try await client.signSolanaMessage(
                SignSolanaMessageOptions(solanaAccount: selectedAddress, message: messageBase64)
            )
            result = "Signature: \(res.signature)"
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Sign Transaction

    func signTransaction() async {
        guard let client, !selectedAddress.isEmpty else {
            error = "Select a Solana account"
            return
        }
        guard !transaction.isEmpty else {
            error = "Enter a base64-encoded transaction"
            return
        }
        isLoading = true
        error = nil

        do {
            let res = try await client.signSolanaTransaction(
                SignSolanaTransactionOptions(solanaAccount: selectedAddress, transaction: transaction)
            )
            result = "Signed TX: \(res.signedTransaction.prefix(40))..."
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Send Transaction

    func sendTransaction() async {
        guard let client, !selectedAddress.isEmpty else {
            error = "Select a Solana account"
            return
        }
        guard !transaction.isEmpty else {
            error = "Enter a base64-encoded transaction"
            return
        }
        isLoading = true
        error = nil

        do {
            let res = try await client.sendSolanaTransaction(
                SendSolanaTransactionOptions(
                    solanaAccount: selectedAddress,
                    network: network,
                    transaction: transaction,
                    useCdpSponsor: useCdpSponsor
                )
            )
            result = "TX Signature: \(res.transactionSignature)"
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func dismissError() {
        error = nil
    }
}
