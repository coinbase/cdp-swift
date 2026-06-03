import Foundation

/// Defines all navigation sections in the app.
enum TabSection: String, CaseIterable, Identifiable {
    case auth = "Auth"
    case accounts = "Accounts"
    case evm = "EVM"
    case solana = "Solana"
    case swap = "Swap"
    case mfa = "MFA"
    case delegation = "Delegation"
    case permissions = "Spend Permissions"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .auth: return "person.circle"
        case .accounts: return "wallet.pass"
        case .evm: return "cube"
        case .solana: return "sparkles"
        case .swap: return "arrow.triangle.2.circlepath"
        case .mfa: return "lock.shield"
        case .delegation: return "person.2"
        case .permissions: return "creditcard"
        }
    }

    /// Whether this section requires the user to be authenticated.
    var requiresAuth: Bool {
        self != .auth
    }
}
