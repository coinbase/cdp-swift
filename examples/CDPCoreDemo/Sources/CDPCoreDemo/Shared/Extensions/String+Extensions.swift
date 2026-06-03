import Foundation

extension String {
    /// Truncates a blockchain address to show first 6 and last 4 characters.
    var truncatedAddress: String {
        guard count > 12 else { return self }
        return "\(prefix(6))...\(suffix(4))"
    }
}
