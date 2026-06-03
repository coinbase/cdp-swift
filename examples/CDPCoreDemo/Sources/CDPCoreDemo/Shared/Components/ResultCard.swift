import SwiftUI

/// Displays an operation result in a styled card.
struct ResultCard: View {
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(content)
                .font(.system(.body, design: .monospaced))
                .textSelection(.enabled)
                .lineLimit(10)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
