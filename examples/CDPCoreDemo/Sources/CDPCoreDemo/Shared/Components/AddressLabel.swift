import SwiftUI

/// Displays a truncated blockchain address with a copy button.
struct AddressLabel: View {
    let address: String

    var body: some View {
        HStack(spacing: 6) {
            Text(address.truncatedAddress)
                .font(.system(.body, design: .monospaced))
            Button {
                copyToClipboard(address)
            } label: {
                Image(systemName: "doc.on.doc")
                    .font(.caption)
            }
            .buttonStyle(.plain)
        }
    }

    private func copyToClipboard(_ text: String) {
        #if os(iOS)
        UIPasteboard.general.string = text
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #endif
    }
}
