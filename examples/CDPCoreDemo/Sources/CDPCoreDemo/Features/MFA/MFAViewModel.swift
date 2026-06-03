import Foundation
import CDPCore

@MainActor
final class MFAViewModel: ObservableObject {
    var client: WalletsClient?

    @Published var isLoading = false
    @Published var error: String?
    @Published var result: String?

    @Published var mfaConfig: MfaConfigState?
    @Published var selectedMethod: MfaMethod = .totp
    @Published var mfaCode = ""
    @Published var verificationInitiated = false

    func getMfaConfig() async {
        guard let client else { return }
        isLoading = true
        error = nil

        do {
            mfaConfig = try await client.getMfaConfig()
            result = mfaConfig != nil ? "Config loaded" : "No MFA config"
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func initiateVerification() async {
        guard let client else { return }
        isLoading = true
        error = nil

        do {
            let flowId = try await client.initiateMfaVerification(
                InitiateMfaVerificationOptions(mfaMethod: selectedMethod)
            )
            verificationInitiated = true
            result = "MFA flow: \(flowId)"
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func submitVerification() async {
        guard let client, mfaCode.count == 6 else { return }
        isLoading = true
        error = nil

        do {
            try await client.submitMfaVerification(
                SubmitMfaVerificationOptions(code: mfaCode, mfaMethod: selectedMethod)
            )
            result = "MFA verification successful"
            verificationInitiated = false
            mfaCode = ""
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func cancelVerification() {
        guard let client else { return }
        Task {
            await client.cancelMfaVerification()
        }
        verificationInitiated = false
        mfaCode = ""
        result = "Verification cancelled"
    }

    func dismissError() {
        error = nil
    }
}
