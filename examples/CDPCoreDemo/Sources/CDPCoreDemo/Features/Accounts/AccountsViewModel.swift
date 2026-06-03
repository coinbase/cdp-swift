import Foundation
import CDPCore

/// Manages account creation operations.
@MainActor
final class AccountsViewModel: ObservableObject {
    var client: WalletsClient?

    @Published var isLoading = false
    @Published var error: String?
    @Published var result: String?

    func createEvmEoaAccount() async {
        guard let client else { return }
        isLoading = true
        error = nil

        do {
            let account = try await client.createEvmEoaAccount()
            result = "Created EOA: \(account.address)"
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func createEvmSmartAccount() async {
        guard let client else { return }
        isLoading = true
        error = nil

        do {
            let account = try await client.createEvmSmartAccount()
            result = "Created Smart Account: \(account.address)"
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func createSolanaAccount() async {
        guard let client else { return }
        isLoading = true
        error = nil

        do {
            let account = try await client.createSolanaAccount()
            result = "Created Solana: \(account.address)"
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func dismissError() {
        error = nil
    }
}
