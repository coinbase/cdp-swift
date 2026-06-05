import Foundation
import CDPCore

/// Reads configuration from the process environment.
///
/// Values are supplied as environment variables on the run scheme
/// (Xcode: Product > Scheme > Edit Scheme > Run > Arguments > Environment Variables).
enum Configuration {
    /// Process environment variables.
    private static let env: [String: String] = ProcessInfo.processInfo.environment

    static let projectId: String = {
        env["CDP_PROJECT_ID"] ?? ""
    }()

    static let useMock: Bool = {
        env["CDP_USE_MOCK"]?.lowercased() == "true"
    }()

    /// Verbose SDK logging. Defaults to true so the [WithAuth]/[AuthManager]
    /// diagnostics surface; set CDP_DEBUG=false to silence.
    static let debugging: Bool = {
        env["CDP_DEBUG"]?.lowercased() != "false"
    }()

    static let basePath: String? = {
        env["CDP_BASE_PATH"]
    }()

    static let ethereumCreateOnLogin: EthereumCreateOnLogin? = {
        guard let value = env["CDP_ETHEREUM_CREATE_ON_LOGIN"] else { return nil }
        return EthereumCreateOnLogin(rawValue: value)
    }()

    static let solanaCreateOnLogin: Bool = {
        env["CDP_SOLANA_CREATE_ON_LOGIN"]?.lowercased() == "true"
    }()

    /// URL scheme used for OAuth redirect callbacks. Must match the
    /// `CFBundleURLSchemes` entry in the iOS app's Info.plist.
    static let callbackURLScheme: String = {
        env["CDP_CALLBACK_URL_SCHEME"] ?? "cdpdemo"
    }()

    static var cdpConfig: CDPCoreConfig {
        CDPCoreConfig(
            projectId: projectId,
            useMock: useMock,
            debugging: debugging,
            basePath: basePath,
            ethereum: ethereumCreateOnLogin.map { EthereumConfig(createOnLogin: $0) },
            solana: solanaCreateOnLogin ? SolanaConfig(createOnLogin: true) : nil,
            callbackURLScheme: callbackURLScheme
        )
    }
}
