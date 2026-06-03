import SwiftUI

/// Reusable OTP code input with verify/cancel actions.
struct OTPVerificationView: View {
    let prompt: String
    @Binding var otp: String
    let isLoading: Bool
    let onVerify: () async -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(prompt)
                .font(.callout)
                .foregroundStyle(.secondary)

            TextField("000000", text: $otp)
                .textFieldStyle(.roundedBorder)
                .font(.system(.title3, design: .monospaced))
                #if os(iOS)
                .keyboardType(.numberPad)
                #endif
                .onChange(of: otp) { newValue in
                    // Limit to 6 digits
                    let filtered = String(newValue.prefix(6).filter(\.isNumber))
                    if filtered != newValue {
                        otp = filtered
                    }
                }

            HStack(spacing: 12) {
                LoadingButton(title: "Verify", isLoading: isLoading) {
                    await onVerify()
                }
                .disabled(otp.count != 6)

                Button("Cancel", role: .cancel) {
                    onCancel()
                }
                .buttonStyle(.bordered)
            }
        }
    }
}
