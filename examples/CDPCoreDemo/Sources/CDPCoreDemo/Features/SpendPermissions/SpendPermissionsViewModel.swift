import Foundation
import CDPCore

@MainActor
final class SpendPermissionsViewModel: ObservableObject {
    var client: WalletsClient?

    @Published var isLoading = false
    @Published var error: String?
    @Published var result: String?

    @Published var permissions: [SpendPermissionResponseObject] = []

    // Form fields
    @Published var selectedSmartAccount = ""
    @Published var network: SendEvmTransactionNetwork = .baseSepolia
    @Published var spender = ""
    @Published var token = ""
    @Published var allowance = ""
    @Published var periodDays = 7
    @Published var endDate = Date().addingTimeInterval(86400 * 30) // +30 days

    func listPermissions() async {
        guard let client, !selectedSmartAccount.isEmpty else {
            error = "Select a smart account"
            return
        }
        isLoading = true
        error = nil

        do {
            let response = try await client.listSpendPermissions(
                ListSpendPermissionsOptions(evmSmartAccount: selectedSmartAccount)
            )
            permissions = response.spendPermissions
            result = "Found \(permissions.count) permission(s)"
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func createPermission() async {
        guard let client, !selectedSmartAccount.isEmpty else {
            error = "Select a smart account"
            return
        }
        isLoading = true
        error = nil

        do {
            let options = CreateSpendPermissionOptions(
                evmSmartAccount: selectedSmartAccount,
                network: network.rawValue,
                spender: spender,
                token: token,
                allowance: allowance,
                periodInDays: periodDays,
                end: Int(endDate.timeIntervalSince1970)
            )
            let response = try await client.createSpendPermission(options)
            result = "Permission created (userOp: \(response.userOpHash), status: \(response.status))"
            await listPermissions()
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func revokePermission(_ permission: SpendPermissionResponseObject) async {
        guard let client else { return }
        isLoading = true
        error = nil

        do {
            let response = try await client.revokeSpendPermission(
                RevokeSpendPermissionOptions(
                    evmSmartAccount: permission.permission.account,
                    network: permission.network,
                    permissionHash: permission.permissionHash
                )
            )
            result = "Revoked (userOp: \(response.userOpHash), status: \(response.status))"
            await listPermissions()
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func dismissError() {
        error = nil
    }
}
