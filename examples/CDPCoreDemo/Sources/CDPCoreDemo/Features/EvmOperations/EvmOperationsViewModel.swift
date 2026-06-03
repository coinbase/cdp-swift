import Foundation
import CDPCore

/// Manages EVM signing and sending operations.
@MainActor
final class EvmOperationsViewModel: ObservableObject {
    // MARK: - Client

    var client: WalletsClient?

    // MARK: - State

    @Published var isLoading = false
    @Published var error: String?
    @Published var result: String?

    // Form fields
    @Published var selectedAddress = ""
    @Published var message = "Hello, CDP Wallets!"
    @Published var hash = "0x" + String(repeating: "ab", count: 32)
    @Published var toAddress = ""
    @Published var value = "0"
    @Published var network: SendEvmTransactionNetwork = .baseSepolia

    // Smart account fields
    @Published var smartAccountAddress = ""
    @Published var callTo = ""
    @Published var callValue = "0"
    @Published var callData = "0x"
    @Published var userOpNetwork: EvmUserOperationNetwork = .baseSepolia
    @Published var useCdpPaymaster = true
    @Published var lastUserOpHash: Hex?

    // MARK: - Sign Message

    func signMessage() async {
        guard let client, !selectedAddress.isEmpty else {
            error = "Select an EVM account"
            return
        }
        isLoading = true
        error = nil

        do {
            let res = try await client.signEvmMessage(
                SignEvmMessageOptions(evmAccount: selectedAddress, message: message)
            )
            result = "Signature: \(res.signature)"
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Sign Hash

    func signHash() async {
        guard let client, !selectedAddress.isEmpty else {
            error = "Select an EVM account"
            return
        }
        isLoading = true
        error = nil

        do {
            let res = try await client.signEvmHash(
                SignEvmHashOptions(evmAccount: selectedAddress, hash: hash)
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
            error = "Select an EVM account"
            return
        }
        isLoading = true
        error = nil

        do {
            let tx = EvmTransaction(
                to: toAddress.isEmpty ? nil : toAddress,
                value: value
            )
            let res = try await client.signEvmTransaction(
                SignEvmTransactionOptions(evmAccount: selectedAddress, transaction: tx)
            )
            result = "Signed TX: \(res.signedTransaction)"
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Send Transaction

    func sendTransaction() async {
        guard let client, !selectedAddress.isEmpty else {
            error = "Select an EVM account"
            return
        }
        isLoading = true
        error = nil

        do {
            let tx = EvmTransaction(
                to: toAddress.isEmpty ? nil : toAddress,
                value: value
            )
            let res = try await client.sendEvmTransaction(
                SendEvmTransactionOptions(
                    evmAccount: selectedAddress,
                    network: network,
                    transaction: tx
                )
            )
            result = "TX Hash: \(res.transactionHash)"
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Send User Operation

    func sendUserOperation() async {
        guard let client, !smartAccountAddress.isEmpty else {
            error = "Select a smart account"
            return
        }
        isLoading = true
        error = nil

        do {
            let call = EvmCall(
                to: callTo,
                value: callValue == "0" ? nil : callValue,
                data: callData == "0x" ? nil : callData
            )
            let res = try await client.sendUserOperation(
                SendUserOperationOptions(
                    evmSmartAccount: smartAccountAddress,
                    network: userOpNetwork,
                    calls: [call],
                    useCdpPaymaster: useCdpPaymaster
                )
            )
            lastUserOpHash = res.userOperationHash
            result = "UserOp Hash: \(res.userOperationHash)"
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Poll User Operation Status

    func pollUserOperation() async {
        guard let client, let hash = lastUserOpHash, !smartAccountAddress.isEmpty else {
            error = "Send a user operation first"
            return
        }
        isLoading = true
        error = nil

        do {
            let res = try await client.getUserOperation(
                GetUserOperationOptions(
                    userOperationHash: hash,
                    evmSmartAccount: smartAccountAddress,
                    network: userOpNetwork
                )
            )
            let txDisplay = res.transactionHash.map { $0.truncatedAddress } ?? "—"
            result = "Status: \(res.status.rawValue) — tx: \(txDisplay)"
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func dismissError() {
        error = nil
    }
}
