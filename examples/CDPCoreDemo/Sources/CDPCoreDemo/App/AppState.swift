import Foundation
import CDPCore

/// Root application state — holds the WalletsClient instance, auth status, and current user.
@MainActor
final class AppState: ObservableObject {
    @Published var client: WalletsClient?
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isInitialized = false
    @Published var error: String?

    func initializeSDK() async {
        do {
            let c = try WalletsClient(config: Configuration.cdpConfig)
            await c.start()
            client = c

            // Subscribe to auth state changes so UI reacts immediately to
            // sign-in/sign-out from any flow (email OTP, SMS OTP, OAuth, custom auth).
            await c.onAuthStateChange { [weak self] user in
                Task { @MainActor in
                    self?.user = user
                    self?.isAuthenticated = (user != nil)
                }
            }

            // Listener does not always fire for the initial state; seed it here.
            let signedIn = await c.isSignedIn()
            if signedIn {
                user = await c.getCurrentUser()
                isAuthenticated = true
            }

            isInitialized = true
        } catch {
            self.error = "SDK initialization failed: \(error.localizedDescription)"
            isInitialized = true // Still show UI so user can retry
        }
    }

    /// Forwards an OAuth redirect URL to the SDK. Wire up via `.onOpenURL`
    /// on the root view so the callback completes when the system delivers
    /// the deep link (e.g. `cdpdemo://cdp-oauth-callback?code=...`).
    func handleOpenURL(_ url: URL) async {
        guard let client else { return }
        do {
            try await client.handleOAuthCode(url: url)
        } catch {
            self.error = "OAuth callback failed: \(error.localizedDescription)"
        }
    }

    func signOut() async {
        guard let client else { return }
        try? await client.signOut()
        user = nil
        isAuthenticated = false
    }

    /// Nuclear reset — signs out, clears all persisted storage (Keychain, UserDefaults,
    /// cookies), and resets in-memory state. Use when the app is stuck in a bad auth state.
    func resetSession() async {
        if let client {
            await client.resetSession()
        }
        user = nil
        isAuthenticated = false
        error = nil
    }
}
