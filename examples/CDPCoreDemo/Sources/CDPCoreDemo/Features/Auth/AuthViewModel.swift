import Foundation
import CDPCore

/// Manages authentication flows: email, SMS, OAuth sign-in + link account.
@MainActor
final class AuthViewModel: ObservableObject {
    // MARK: - Dependencies

    var client: WalletsClient?
    weak var appState: AppState?

    // MARK: - Sign In State

    enum Step {
        case input
        case otp
    }

    @Published var emailStep: Step = .input
    @Published var smsStep: Step = .input

    @Published var email = ""
    @Published var phoneNumber = ""
    @Published var emailOtp = ""
    @Published var smsOtp = ""

    @Published var emailFlowId: String?
    @Published var smsFlowId: String?

    @Published var isLoading = false
    @Published var error: String?
    @Published var result: String?
    @Published var accessToken: String?

    // MARK: - Link Account State

    @Published var linkEmail = ""
    @Published var linkPhone = ""
    @Published var linkEmailFlowId: String?
    @Published var linkSmsFlowId: String?
    @Published var linkEmailOtp = ""
    @Published var linkSmsOtp = ""
    @Published var linkEmailStep: Step = .input
    @Published var linkSmsStep: Step = .input

    // MARK: - Validation

    var isEmailValid: Bool {
        let pattern = #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }

    var isPhoneValid: Bool {
        phoneNumber.count >= 10
    }

    var isEmailOtpValid: Bool {
        emailOtp.count == 6
    }

    var isSmsOtpValid: Bool {
        smsOtp.count == 6
    }

    // MARK: - Email Sign In

    func signInWithEmail() async {
        guard let client, isEmailValid else { return }
        isLoading = true
        error = nil

        do {
            let res = try await client.signInWithEmail(SignInWithEmailOptions(email: email))
            emailFlowId = res.flowId
            emailStep = .otp
            result = "Flow ID: \(res.flowId)"
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func verifyEmailOtp() async {
        guard let client, let flowId = emailFlowId, isEmailOtpValid else { return }
        isLoading = true
        error = nil

        do {
            let res = try await client.verifyEmailOTP(VerifyEmailOTPOptions(flowId: flowId, otp: emailOtp))
            result = "Signed in as: \(res.user.userId)"
            appState?.user = res.user
            appState?.isAuthenticated = true
            resetEmailFlow()
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func cancelEmailFlow() {
        resetEmailFlow()
    }

    private func resetEmailFlow() {
        emailStep = .input
        emailOtp = ""
        emailFlowId = nil
    }

    // MARK: - SMS Sign In

    func signInWithSms() async {
        guard let client, isPhoneValid else { return }
        isLoading = true
        error = nil

        do {
            let res = try await client.signInWithSms(SignInWithSmsOptions(phoneNumber: phoneNumber))
            smsFlowId = res.flowId
            smsStep = .otp
            result = "Flow ID: \(res.flowId)"
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func verifySmsOtp() async {
        guard let client, let flowId = smsFlowId, isSmsOtpValid else { return }
        isLoading = true
        error = nil

        do {
            let res = try await client.verifySmsOTP(VerifySmsOTPOptions(flowId: flowId, otp: smsOtp))
            result = "Signed in as: \(res.user.userId)"
            appState?.user = res.user
            appState?.isAuthenticated = true
            resetSmsFlow()
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func cancelSmsFlow() {
        resetSmsFlow()
    }

    private func resetSmsFlow() {
        smsStep = .input
        smsOtp = ""
        smsFlowId = nil
    }

    // MARK: - OAuth Sign In

    func signInWithOAuth(_ provider: OAuth2ProviderType) async {
        guard let client else { return }
        isLoading = true
        error = nil

        do {
            let flowId = try await client.signInWithOAuth(providerType: provider)
            result = "OAuth flow started: \(flowId)"
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Link Email

    func linkEmailAccount() async {
        guard let client else { return }
        isLoading = true
        error = nil

        do {
            let flowId = try await client.linkEmail(linkEmail)
            linkEmailFlowId = flowId
            linkEmailStep = .otp
            result = "Link email flow: \(flowId)"
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func verifyLinkEmailOtp() async {
        guard let client, let flowId = linkEmailFlowId, linkEmailOtp.count == 6 else { return }
        isLoading = true
        error = nil

        do {
            _ = try await client.verifyEmailOTP(VerifyEmailOTPOptions(flowId: flowId, otp: linkEmailOtp))
            result = "Email linked successfully"
            linkEmailStep = .input
            linkEmailOtp = ""
            linkEmailFlowId = nil
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Link SMS

    func linkSmsAccount() async {
        guard let client else { return }
        isLoading = true
        error = nil

        do {
            let flowId = try await client.linkSms(linkPhone)
            linkSmsFlowId = flowId
            linkSmsStep = .otp
            result = "Link SMS flow: \(flowId)"
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func verifyLinkSmsOtp() async {
        guard let client, let flowId = linkSmsFlowId, linkSmsOtp.count == 6 else { return }
        isLoading = true
        error = nil

        do {
            _ = try await client.verifySmsOTP(VerifySmsOTPOptions(flowId: flowId, otp: linkSmsOtp))
            result = "SMS linked successfully"
            linkSmsStep = .input
            linkSmsOtp = ""
            linkSmsFlowId = nil
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Link OAuth

    func linkOAuthAccount(_ provider: OAuth2ProviderType) async {
        guard let client else { return }
        isLoading = true
        error = nil

        do {
            let flowId = try await client.linkOAuth(providerType: provider)
            result = "Link OAuth flow: \(flowId)"
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Session

    func signOut() async {
        guard let client else { return }
        isLoading = true
        error = nil

        do {
            try await client.signOut()
            result = "Signed out"
            accessToken = nil
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func fetchAccessToken() async {
        guard let client else { return }
        isLoading = true
        error = nil

        do {
            accessToken = try await client.getAccessToken()
            result = accessToken.map { "Token: \($0.prefix(20))..." }
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func dismissError() {
        error = nil
    }
}
