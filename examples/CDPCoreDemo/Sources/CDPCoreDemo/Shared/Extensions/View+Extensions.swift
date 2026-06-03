import SwiftUI

extension View {
    /// Applies consistent card styling.
    func cardStyle() -> some View {
        self
            .padding()
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }
}
