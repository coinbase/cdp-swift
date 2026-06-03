import Foundation
import CDPCore

/// Reads configuration from a .env file (falling back to process environment variables).
enum Configuration {
    /// Parsed .env entries merged with process environment (process env takes priority).
    private static let env: [String: String] = {
        var combined = loadDotEnv()
        // Process environment overrides .env file
        for (key, value) in ProcessInfo.processInfo.environment {
            combined[key] = value
        }
        return combined
    }()

    static let projectId: String = {
        env["CDP_PROJECT_ID"] ?? ""
    }()

    static let useMock: Bool = {
        env["CDP_USE_MOCK"]?.lowercased() == "true"
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
            basePath: basePath,
            ethereum: ethereumCreateOnLogin.map { EthereumConfig(createOnLogin: $0) },
            solana: solanaCreateOnLogin ? SolanaConfig(createOnLogin: true) : nil,
            callbackURLScheme: callbackURLScheme
        )
    }

    // MARK: - .env file parsing

    /// Searches for a .env file relative to the package directory or current working directory.
    private static func loadDotEnv() -> [String: String] {
        let candidates = [
            // 1. Bundled resource (copied into app bundle by SPM)
            Bundle.main.path(forResource: ".env", ofType: nil),
            // 2. Walk up from bundle looking for .env alongside Package.swift
            bundleRelativePath(),
            // 3. Current working directory (e.g. `swift run` from terminal)
            FileManager.default.currentDirectoryPath + "/.env",
        ].compactMap { $0 }

        for path in candidates {
            if let contents = try? String(contentsOfFile: path, encoding: .utf8) {
                return parse(contents)
            }
        }
        return [:]
    }

    /// Walks up from the executable/bundle location looking for .env.
    private static func bundleRelativePath() -> String? {
        var url = Bundle.main.bundleURL
        // Walk up at most 10 levels looking for .env alongside Package.swift
        for _ in 0..<10 {
            let envFile = url.appendingPathComponent(".env")
            let packageFile = url.appendingPathComponent("Package.swift")
            if FileManager.default.fileExists(atPath: packageFile.path),
               FileManager.default.fileExists(atPath: envFile.path) {
                return envFile.path
            }
            url = url.deletingLastPathComponent()
        }
        return nil
    }

    /// Parses KEY=VALUE lines, ignoring comments and blank lines.
    private static func parse(_ contents: String) -> [String: String] {
        var result: [String: String] = [:]
        for line in contents.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty, !trimmed.hasPrefix("#") else { continue }
            guard let eqIndex = trimmed.firstIndex(of: "=") else { continue }
            let key = String(trimmed[trimmed.startIndex..<eqIndex]).trimmingCharacters(in: .whitespaces)
            var value = String(trimmed[trimmed.index(after: eqIndex)...]).trimmingCharacters(in: .whitespaces)
            // Strip surrounding quotes
            if (value.hasPrefix("\"") && value.hasSuffix("\"")) ||
               (value.hasPrefix("'") && value.hasSuffix("'")) {
                value = String(value.dropFirst().dropLast())
            }
            result[key] = value
        }
        return result
    }
}
