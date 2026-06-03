import SwiftUI
import CDPCore

/// Link additional auth methods to the current user.
struct LinkAccountView: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Link Account", subtitle: "Add authentication methods")

            // Link Email
            VStack(alignment: .leading, spacing: 8) {
                Text("Email").font(.subheadline.bold())

                switch viewModel.linkEmailStep {
                case .input:
                    TextField("email@example.com", text: $viewModel.linkEmail)
                        .textFieldStyle(.roundedBorder)
                        #if os(iOS)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        #endif

                    LoadingButton(title: "Link Email", isLoading: viewModel.isLoading) {
                        await viewModel.linkEmailAccount()
                    }
                    .disabled(viewModel.linkEmail.isEmpty)

                case .otp:
                    OTPVerificationView(
                        prompt: "Verify code sent to \(viewModel.linkEmail)",
                        otp: $viewModel.linkEmailOtp,
                        isLoading: viewModel.isLoading,
                        onVerify: { await viewModel.verifyLinkEmailOtp() },
                        onCancel: {
                            viewModel.linkEmailStep = .input
                            viewModel.linkEmailOtp = ""
                            viewModel.linkEmailFlowId = nil
                        }
                    )
                }
            }

            Divider()

            // Link SMS
            VStack(alignment: .leading, spacing: 8) {
                Text("Phone").font(.subheadline.bold())

                switch viewModel.linkSmsStep {
                case .input:
                    TextField("+14155552671", text: $viewModel.linkPhone)
                        .textFieldStyle(.roundedBorder)
                        #if os(iOS)
                        .keyboardType(.phonePad)
                        #endif

                    LoadingButton(title: "Link Phone", isLoading: viewModel.isLoading) {
                        await viewModel.linkSmsAccount()
                    }
                    .disabled(viewModel.linkPhone.isEmpty)

                case .otp:
                    OTPVerificationView(
                        prompt: "Verify code sent to \(viewModel.linkPhone)",
                        otp: $viewModel.linkSmsOtp,
                        isLoading: viewModel.isLoading,
                        onVerify: { await viewModel.verifyLinkSmsOtp() },
                        onCancel: {
                            viewModel.linkSmsStep = .input
                            viewModel.linkSmsOtp = ""
                            viewModel.linkSmsFlowId = nil
                        }
                    )
                }
            }

            Divider()

            // Link OAuth
            VStack(alignment: .leading, spacing: 8) {
                Text("OAuth").font(.subheadline.bold())

                HStack(spacing: 12) {
                    ForEach([OAuth2ProviderType.google, .apple], id: \.self) { provider in
                        Button("Link \(provider.displayName)") {
                            Task { await viewModel.linkOAuthAccount(provider) }
                        }
                        .buttonStyle(.bordered)
                        .disabled(viewModel.isLoading)
                    }
                }
            }
        }
        .cardStyle()
    }
}
