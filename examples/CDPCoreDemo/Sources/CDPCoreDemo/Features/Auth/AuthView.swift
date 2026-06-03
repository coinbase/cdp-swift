import SwiftUI
import CDPCore

/// Main authentication section showing sign-in, link, and session controls.
struct AuthView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Error banner
                if let error = viewModel.error {
                    ErrorBanner(message: error, onDismiss: viewModel.dismissError)
                }

                // Result display
                if let result = viewModel.result {
                    ResultCard(title: "Result", content: result)
                }

                // User profile
                if let user = appState.user {
                    userProfileSection(user)
                }

                // Sign in sections (only when not authenticated)
                if !appState.isAuthenticated {
                    emailSignInSection
                    smsSignInSection
                    oauthSignInSection
                }

                // Session controls (when authenticated)
                if appState.isAuthenticated {
                    sessionSection
                    linkAccountSection
                }

                // Reset button — always visible for debugging stale state
                resetSection
            }
            .padding()
        }
        .task {
            viewModel.client = appState.client
            viewModel.appState = appState
        }
    }

    // MARK: - User Profile

    private func userProfileSection(_ user: User) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Current User", subtitle: user.userId)

            if let email = user.authenticationMethods.email?.email {
                Label(email, systemImage: "envelope")
                    .font(.callout)
            }
            if let phone = user.authenticationMethods.sms?.phoneNumber {
                Label(phone, systemImage: "phone")
                    .font(.callout)
            }
            if let evmAccounts = user.evmAccountObjects {
                ForEach(evmAccounts, id: \.address) { account in
                    Label("EOA: \(account.address.truncatedAddress)", systemImage: "cube")
                        .font(.callout)
                }
            }
            if let smartAccounts = user.evmSmartAccountObjects {
                ForEach(smartAccounts, id: \.address) { account in
                    Label("Smart: \(account.address.truncatedAddress)", systemImage: "cube.fill")
                        .font(.callout)
                }
            }
            if let solanaAccounts = user.solanaAccountObjects {
                ForEach(solanaAccounts, id: \.address) { account in
                    Label("Solana: \(account.address.truncatedAddress)", systemImage: "sparkles")
                        .font(.callout)
                }
            }
        }
        .cardStyle()
    }

    // MARK: - Email Sign In

    private var emailSignInSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Email Sign In")

            switch viewModel.emailStep {
            case .input:
                TextField("email@example.com", text: $viewModel.email)
                    .textFieldStyle(.roundedBorder)
                    #if os(iOS)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    #endif

                LoadingButton(title: "Send Code", isLoading: viewModel.isLoading) {
                    await viewModel.signInWithEmail()
                }
                .disabled(!viewModel.isEmailValid)

            case .otp:
                OTPVerificationView(
                    prompt: "We sent a code to \(viewModel.email)",
                    otp: $viewModel.emailOtp,
                    isLoading: viewModel.isLoading,
                    onVerify: { await viewModel.verifyEmailOtp() },
                    onCancel: viewModel.cancelEmailFlow
                )
            }
        }
        .cardStyle()
    }

    // MARK: - SMS Sign In

    private var smsSignInSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "SMS Sign In")

            switch viewModel.smsStep {
            case .input:
                TextField("+14155552671", text: $viewModel.phoneNumber)
                    .textFieldStyle(.roundedBorder)
                    #if os(iOS)
                    .keyboardType(.phonePad)
                    #endif

                LoadingButton(title: "Send Code", isLoading: viewModel.isLoading) {
                    await viewModel.signInWithSms()
                }
                .disabled(!viewModel.isPhoneValid)

            case .otp:
                OTPVerificationView(
                    prompt: "We sent a code to \(viewModel.phoneNumber)",
                    otp: $viewModel.smsOtp,
                    isLoading: viewModel.isLoading,
                    onVerify: { await viewModel.verifySmsOtp() },
                    onCancel: viewModel.cancelSmsFlow
                )
            }
        }
        .cardStyle()
    }

    // MARK: - OAuth

    private var oauthSignInSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "OAuth Sign In")

            HStack(spacing: 12) {
                ForEach([OAuth2ProviderType.google, .apple], id: \.self) { provider in
                    Button(provider.displayName) {
                        Task { await viewModel.signInWithOAuth(provider) }
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.isLoading)
                }
            }
        }
        .cardStyle()
    }

    // MARK: - Session

    private var sessionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Session")

            HStack(spacing: 12) {
                LoadingButton(title: "Sign Out", isLoading: viewModel.isLoading) {
                    await appState.signOut()
                }

                LoadingButton(title: "Get Token", isLoading: viewModel.isLoading) {
                    await viewModel.fetchAccessToken()
                }
            }

            if let token = viewModel.accessToken {
                ResultCard(title: "Access Token", content: token)
            }
        }
        .cardStyle()
    }

    // MARK: - Link Account

    private var linkAccountSection: some View {
        LinkAccountView(viewModel: viewModel)
    }

    // MARK: - Reset

    private var resetSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Debug")

            Button(role: .destructive) {
                Task {
                    await appState.resetSession()
                }
            } label: {
                Label("Reset Session", systemImage: "trash")
            }
            .buttonStyle(.bordered)
            .tint(.red)
        }
        .cardStyle()
    }
}

// MARK: - OAuth2ProviderType Display

extension OAuth2ProviderType {
    var displayName: String {
        switch self {
        case .google: return "Google"
        case .apple: return "Apple"
        case .x: return "X"
        case .telegram: return "Telegram"
        }
    }
}
