import Foundation
import CDPCore

@MainActor
final class DelegationViewModel: ObservableObject {
    var client: WalletsClient?

    @Published var isLoading = false
    @Published var error: String?
    @Published var result: String?

    @Published var delegationInfo: DelegationInfo?
    @Published var expiresAt = Date().addingTimeInterval(86400) // default: +1 day

    func getDelegation() async {
        guard let client else { return }
        isLoading = true
        error = nil

        do {
            delegationInfo = try await client.getDelegation()
            if let info = delegationInfo {
                result = "Delegation active: \(info.isActive)"
            } else {
                result = "No delegation found"
            }
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func createDelegation() async {
        guard let client else { return }
        isLoading = true
        error = nil

        do {
            try await client.createDelegation(
                CreateDelegationOptions(expiresAt: expiresAt)
            )
            result = "Delegation created (expires: \(expiresAt.formatted()))"
            await getDelegation()
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func revokeDelegation() async {
        guard let client else { return }
        isLoading = true
        error = nil

        do {
            try await client.revokeDelegation()
            result = "Delegation revoked"
            delegationInfo = nil
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func dismissError() {
        error = nil
    }
}
