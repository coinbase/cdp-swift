import SwiftUI
import CDPCore

/// MFA enrollment and verification management.
struct MFAView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = MFAViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let error = viewModel.error {
                    ErrorBanner(message: error, onDismiss: viewModel.dismissError)
                }

                if let result = viewModel.result {
                    ResultCard(title: "Result", content: result)
                }

                configSection
                verificationSection
            }
            .padding()
        }
        .task {
            viewModel.client = appState.client
        }
    }

    // MARK: - Config

    private var configSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "MFA Configuration")

            LoadingButton(title: "Get MFA Config", isLoading: viewModel.isLoading) {
                await viewModel.getMfaConfig()
            }

            if let config = viewModel.mfaConfig {
                VStack(alignment: .leading, spacing: 4) {
                    Label("TOTP: \(config.totpEnabled ? "Enabled" : "Disabled")", systemImage: "key")
                    Label("SMS: \(config.smsEnabled ? "Enabled" : "Disabled")", systemImage: "message")
                    if let window = config.verificationWindowSeconds {
                        Label("Window: \(window)s", systemImage: "clock")
                    }
                }
                .font(.callout)
            }
        }
        .cardStyle()
    }

    // MARK: - Verification

    private var verificationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "MFA Verification")

            Picker("Method", selection: $viewModel.selectedMethod) {
                Text("TOTP").tag(MfaMethod.totp)
                Text("SMS").tag(MfaMethod.sms)
            }
            .pickerStyle(.segmented)

            LoadingButton(title: "Initiate Verification", isLoading: viewModel.isLoading) {
                await viewModel.initiateVerification()
            }

            if viewModel.verificationInitiated {
                TextField("6-digit code", text: $viewModel.mfaCode)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.title3, design: .monospaced))
                    #if os(iOS)
                    .keyboardType(.numberPad)
                    #endif

                HStack(spacing: 12) {
                    LoadingButton(title: "Submit", isLoading: viewModel.isLoading) {
                        await viewModel.submitVerification()
                    }
                    .disabled(viewModel.mfaCode.count != 6)

                    Button("Cancel") {
                        viewModel.cancelVerification()
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .cardStyle()
    }
}
