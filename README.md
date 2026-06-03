# Coinbase Developer Platform (CDP) Swift SDK

[![Swift 5.9+](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2016+%20|%20macOS%2013+-blue.svg)](https://developer.apple.com/swift/)
[![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)](https://github.com/coinbase/cdp-swift/blob/main/LICENSE)

## Table of Contents

- [Overview](#overview)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Authentication](#authentication)
- [Account Linking](#account-linking)
- [Sessions](#sessions)
- [Accounts](#accounts)
- [Signing](#signing)
- [Sending Transactions](#sending-transactions)
- [Swaps](#swaps)
- [Spend Permissions](#spend-permissions)
- [Delegation](#delegation)
- [EIP-7702](#eip-7702)
- [MFA](#mfa)
- [Error Handling](#error-handling)
- [Testing Your Integration](#testing-your-integration)
- [Documentation](#documentation)
- [License](#license)
- [Support](#support)
- [Security](#security)

## Overview

The CDP Swift SDK is an embedded-wallets solution for iOS and macOS applications. It provides end-user authentication, account creation, signing, swaps, and transaction broadcasting through the [Coinbase Developer Platform](https://docs.cdp.coinbase.com/).

The SDK ships a single library target — **CDPCore** — exposing an actor-based, async/await API.

> [!TIP]
> If you're looking to contribute to the SDK, please see the [Contributing Guide](CONTRIBUTING.md).

## Requirements

- Swift 5.9+ (Xcode 15+)
- iOS 16+ / macOS 13+

## Installation

Add the SDK to your Swift package dependencies using exact version pinning:

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/coinbase/cdp-swift", exact: "0.1.0"),
]
```

> [!IMPORTANT]
> Always use `.exact("x.y.z")` version pinning — not range-based specifiers like `from:` or `.upToNextMajor`. The SDK distributes a pre-built binary framework whose checksum changes with every release; range-based resolution can pull an incompatible binary.

Then add the product to your target:

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "CDPCore", package: "cdp-swift"),
    ]
)
```

## Quick Start

```swift
import CDPCore
import SwiftUI

@main
struct MyApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .task { await appState.initializeSDK() }
                .onOpenURL { url in
                    Task { await appState.handleOpenURL(url) }
                }
        }
    }
}

@MainActor
final class AppState: ObservableObject {
    @Published var client: WalletsClient?
    @Published var user: User?

    func initializeSDK() async {
        let c = try? WalletsClient(config: CDPCoreConfig(projectId: "your-project-id"))
        await c?.start()
        client = c

        await c?.onAuthStateChange { [weak self] user in
            Task { @MainActor in self?.user = user }
        }
    }

    func handleOpenURL(_ url: URL) async {
        try? await client?.handleOAuthCode(url: url)
    }
}
```

`WalletsClient` is an `actor` — every public method is `async`. Always call `start()` after init to restore any persisted session and register the default Apple platform services (Keychain, crypto, OAuth). For OAuth redirects, forward incoming URLs to `handleOAuthCode(url:)` via `.onOpenURL`.

## Configuration

`CDPCoreConfig` controls SDK behaviour. Only `projectId` is required.

```swift
let config = CDPCoreConfig(
    projectId: "your-project-id",
    customAuth: nil,                  // BYO identity provider — see Authentication
    useMock: false,                   // true → MockWalletsAPIClient for previews / offline
    debugging: false,                 // verbose logging
    basePath: nil,                    // override CDP API base URL
    disableAnalytics: false,
    ethereum: EthereumConfig(
        createOnLogin: .smart,        // .smart | .eoa | nil
        enableSpendPermissions: true
    ),
    solana: SolanaConfig(createOnLogin: true),
    callbackURLScheme: "myapp"        // OAuth deep-link scheme (defaults to bundleIdentifier)
)
```

For custom platform services (alternative storage, crypto, OAuth), call `PlatformRegistry.shared.setPlatformServices(...)` **before** `start()`.

## Authentication

The SDK supports five sign-in flows: Email OTP, SMS OTP, OAuth (Google/Apple/Telegram/…), Sign-In With Ethereum (SIWE), and developer-issued JWT (BYO auth).

### Email OTP

```swift
let flow = try await client.signInWithEmail(SignInWithEmailOptions(email: "user@example.com"))
let verified = try await client.verifyEmailOTP(
    VerifyEmailOTPOptions(flowId: flow.flowId, otp: "123456")
)
print("Signed in as \(verified.user.userId)")
```

### SMS OTP

```swift
let flow = try await client.signInWithSms(SignInWithSmsOptions(phoneNumber: "+14155552671"))
let verified = try await client.verifySmsOTP(
    VerifySmsOTPOptions(flowId: flow.flowId, otp: "123456")
)
```

### OAuth

`signInWithOAuth` returns a flow ID and opens the provider's auth page. The provider redirects back to your app via the URL scheme configured in `CDPCoreConfig.callbackURLScheme`; forward that URL to `handleOAuthCode` (see Quick Start).

```swift
let flowId = try await client.signInWithOAuth(providerType: .google)
// Redirect arrives via .onOpenURL → handleOAuthCode(url:) completes the flow.
```

Supported providers via `OAuth2ProviderType`: `.google`, `.apple`, `.telegram`, plus other configured providers.

For manual code exchange (no deep link):

```swift
let result = try await client.verifyOAuth(
    VerifyOAuthOptions(flowId: flowId, code: code, providerType: .google)
)
```

Observe in-progress OAuth state:

```swift
await client.onOAuthStateChange { state in
    // state?.status: .pending | .completed | .failed | .cancelled
}
```

### Sign-In With Ethereum (SIWE)

```swift
let challenge = try await client.signInWithSiwe(SignInWithSiweOptions(...))
// Sign challenge.message with the user's wallet, then:
let result = try await client.verifySiweSignature(
    VerifySiweSignatureOptions(flowId: challenge.flowId, signature: signature)
)
```

### Custom Auth (BYO Identity Provider)

Pass a `CustomAuth` closure that returns a JWT from your identity provider. Once configured, call `authenticateWithJWT()` to sign in.

```swift
let config = CDPCoreConfig(
    projectId: "your-project-id",
    customAuth: CustomAuth { try await myIdentityProvider.currentJwt() }
)
let client = try WalletsClient(config: config)
await client.start()

let result = try await client.authenticateWithJWT()
print("New user: \(result.isNewUser)")
```

The SDK invokes `getJwt` automatically whenever a fresh bearer token is needed.

## Account Linking

Add additional auth methods to an already signed-in user.

```swift
let flowId = try await client.linkEmail("alt@example.com")
_ = try await client.verifyEmailOTP(VerifyEmailOTPOptions(flowId: flowId, otp: "123456"))

let smsFlowId = try await client.linkSms("+14155552671")
let oauthFlowId = try await client.linkOAuth(providerType: .google)
let appleFlowId = try await client.linkApple()
let googleFlowId = try await client.linkGoogle()
let telegramFlowId = try await client.linkTelegram()
```

## Sessions

```swift
let user = await client.getCurrentUser()                   // User?
let signedIn = await client.isSignedIn()                   // Bool
let token = try await client.getAccessToken()              // String?
let expiry = await client.getAccessTokenExpiration()       // Int? (epoch seconds)
try await client.signOut()                                  // clears session
await client.resetSession()                                 // nuclear: Keychain + cookies + state

await client.onAuthStateChange { user in
    // Called on sign-in / sign-out / token refresh.
}
```

## Accounts

```swift
let eoa = try await client.createEvmEoaAccount()                 // EndUserEvmAccount
let smart = try await client.createEvmSmartAccount()             // EndUserEvmSmartAccount (requires an EOA owner)
let solana = try await client.createSolanaAccount()              // EndUserSolanaAccount
```

All three accept an optional `idempotencyKey: String`. Existing accounts are exposed on the `User`:

```swift
let user = await client.getCurrentUser()
user?.evmAccountObjects        // [EndUserEvmAccount]?
user?.evmSmartAccountObjects   // [EndUserEvmSmartAccount]?
user?.solanaAccountObjects     // [EndUserSolanaAccount]?
```

## Signing

All signing operations are MFA-gated when the project enables MFA — see [MFA](#mfa).

### EVM message / hash

```swift
let msg = try await client.signEvmMessage(
    SignEvmMessageOptions(evmAccount: address, message: "Hello, CDP")
)

let hash = try await client.signEvmHash(
    SignEvmHashOptions(evmAccount: address, hash: "0xabc…")
)
```

### EVM transaction (EIP-1559)

```swift
let tx = EvmTransaction(to: "0x…", value: "1000000000000000")
let signed = try await client.signEvmTransaction(
    SignEvmTransactionOptions(evmAccount: address, transaction: tx)
)
// signed.signedTransaction is RLP-encoded with the 0x02 EIP-1559 prefix.
```

### EVM typed data (EIP-712)

```swift
let typedData = EIP712TypedData(
    domain: EIP712Domain(name: "MyDapp", version: "1", chainId: 84532,
                         verifyingContract: "0x…"),
    types: ["EIP712Domain": [...], "Message": [["name": "content", "type": "string"]]],
    primaryType: "Message",
    message: ["content": AnyCodable("Hello")]
)
let result = try await client.signEvmTypedData(
    SignEvmTypedDataOptions(evmAccount: address, typedData: typedData)
)
```

### Solana message / transaction

Solana payloads are passed through as base64.

```swift
let messageBase64 = Data("Hello".utf8).base64EncodedString()
let sig = try await client.signSolanaMessage(
    SignSolanaMessageOptions(solanaAccount: address, message: messageBase64)
)

let signed = try await client.signSolanaTransaction(
    SignSolanaTransactionOptions(solanaAccount: address, transaction: base64Tx)
)
```

## Sending Transactions

### EVM EOA

```swift
let tx = EvmTransaction(to: "0x…", value: "1000000000000000")
let res = try await client.sendEvmTransaction(
    SendEvmTransactionOptions(
        evmAccount: address,
        network: .baseSepolia,
        transaction: tx
    )
)
// res.transactionHash
```

USDC helpers (auto-encodes ERC-20 `transfer`):

```swift
try await client.sendEvmUsdc(SendEvmUsdcOptions(
    evmAccount: address,
    to: recipient,
    amount: "1.5",                     // decimal string, e.g. "1.5" USDC
    network: .baseSepolia
))
```

### EVM Smart Account (User Operation)

```swift
let call = EvmCall(to: contract, value: "0", data: callData)
let opRes = try await client.sendUserOperation(
    SendUserOperationOptions(
        evmSmartAccount: smartAccountAddress,
        network: .baseSepolia,
        calls: [call],
        useCdpPaymaster: true
    )
)
let hash: Hex = opRes.userOperationHash

// Poll status:
let status = try await client.getUserOperation(
    GetUserOperationOptions(
        userOperationHash: hash,
        evmSmartAccount: smartAccountAddress,
        network: .baseSepolia
    )
)
// status.status.rawValue, status.transactionHash
```

Smart-account USDC convenience:

```swift
try await client.sendEvmSmartAccountUsdc(SendEvmSmartAccountUsdcOptions(
    evmSmartAccount: smartAccountAddress,
    to: recipient,
    amount: "1.5",
    network: .baseSepolia,
    useCdpPaymaster: true
))
```

### Solana

```swift
let res = try await client.sendSolanaTransaction(
    SendSolanaTransactionOptions(
        solanaAccount: address,
        network: .solanaDevnet,
        transaction: base64Tx,
        useCdpSponsor: false
    )
)
// res.transactionSignature

try await client.sendSolanaUsdc(SendSolanaUsdcOptions(
    solanaAccount: address,
    to: recipient,
    amount: "1.5",
    network: .solanaDevnet
))
```

Network enums: `SendEvmTransactionNetwork`, `SendEvmUsdcNetwork`, `EvmUserOperationNetwork`, `SendSolanaTransactionNetwork`, `SendSolanaUsdcNetwork`.

## Swaps

```swift
let price = try await client.getSwapPrice(GetSwapPriceOptions(
    fromToken: usdc, toToken: weth, fromAmount: "1000000",
    account: nil,                       // auto-resolve taker (prefers smart account over EOA)
    network: .base, slippageBps: 100
))
guard price.liquidityAvailable else { return }
print("Min out: \(price.minToAmount ?? "?")")

let result = try await client.executeSwap(ExecuteSwapOptions(
    fromToken: usdc, toToken: weth, fromAmount: "1000000",
    account: takerAddress, network: .base, slippageBps: 100
))
switch result {
case .eoaResult(let txHash): print("EOA tx: \(txHash)")
case .smartAccountResult(let opHash): print("UserOp: \(opHash)")
}
```

`useCdpPaymaster` and `paymasterUrl` are mutually exclusive — passing both throws `CDPCoreError.inputValidation`.

## Spend Permissions

Requires `EthereumConfig(enableSpendPermissions: true)` and an EVM smart account.

```swift
let created = try await client.createSpendPermission(CreateSpendPermissionOptions(
    evmSmartAccount: smartAccount,
    network: "base-sepolia",
    spender: spenderAddress,
    token: "eth",                       // "eth" or ERC-20 address
    allowance: "1000000000000000",      // wei
    periodInDays: 7,
    end: Int(Date().addingTimeInterval(86400 * 30).timeIntervalSince1970)
))
// created.userOpHash, created.status

let list = try await client.listSpendPermissions(
    ListSpendPermissionsOptions(evmSmartAccount: smartAccount)
)
for permission in list.spendPermissions {
    print(permission.permissionHash, permission.revoked)
}

let revoked = try await client.revokeSpendPermission(RevokeSpendPermissionOptions(
    evmSmartAccount: smartAccount,
    network: permission.network,
    permissionHash: permission.permissionHash
))
```

## Delegation

Developer-key delegation lets your backend perform certain actions on behalf of the user.

```swift
let info = try await client.getDelegation()         // DelegationInfo?

try await client.createDelegation(
    CreateDelegationOptions(expiresAt: Date().addingTimeInterval(86400))
)

try await client.revokeDelegation()
```

Address-scoped variants are available: `getDelegationForAddress`, `createDelegationForAddress`, `revokeDelegationForAddress`.

## EIP-7702

Delegate an EOA to a smart-account implementation contract.

```swift
let opId = try await client.createEvmEip7702Delegation(
    CreateEvmEip7702DelegationOptions(address: eoa, network: "base-sepolia")
)

let success = try await client.waitForEvmEip7702Delegation(
    WaitForEvmEip7702DelegationOptions(delegationOperationId: opId)
)
```

## MFA

Sensitive actions (signing, sending, spend permissions, delegation) automatically gate on MFA when enabled for the project. You must register an MFA listener via `MFAState` — without one, those actions throw `CDPCoreError.mfa(.listenerRequired, _)`.

```swift
let config = try await client.getMfaConfig()        // MfaConfigState?

// Enrollment (TOTP returns authUrl + secret to provision the authenticator app)
let enroll = try await client.initiateMfaEnrollment(
    InitiateMfaEnrollmentOptions(mfaMethod: .totp)
)
switch enroll {
case .totp(let authUrl, let secret): break   // provision authenticator app
case .sms(let success): break
}
try await client.submitMfaEnrollment(
    SubmitMfaEnrollmentOptions(code: "123456", mfaMethod: .totp)
)

// Verification (explicit, e.g. before a sensitive action)
let flowId = try await client.initiateMfaVerification(
    InitiateMfaVerificationOptions(mfaMethod: .totp)
)
try await client.submitMfaVerification(
    SubmitMfaVerificationOptions(code: "123456", mfaMethod: .totp)
)
await client.cancelMfaVerification()
```

## Error Handling

All SDK errors are cases of `CDPCoreError`:

| Case | Meaning |
|---|---|
| `.notInitialized(String)` | `start()` not called |
| `.notSignedIn(String)` | Operation requires an authenticated user |
| `.alreadySignedIn(String)` | Sign-in attempted while already authenticated |
| `.accountNotFound(String)` | The current user does not own the supplied address |
| `.inputValidation(String)` | Invalid argument (address format, missing field, conflicting options) |
| `.validation(String)` | Server-side validation error |
| `.mfa(MfaErrorCode, String)` | `.superseded` / `.cancelled` / `.listenerRequired` |
| `.swap(SwapErrorCode, String)` | `.insufficientLiquidity` / `.insufficientAllowance` / `.insufficientBalance` / `.transactionSimulationFailed` |
| `.customAuth(String)` | BYO-auth misconfiguration or JWT failure |
| `.api(statusCode:errorType:message:correlationId:)` | API returned an error |
| `.network(String)` | Transport-level failure |
| `.internal(String)` | Unexpected internal state |

Inspect specific cases with pattern matching:

```swift
do {
    _ = try await client.getSwapPrice(options)
} catch let CDPCoreError.swap(code, message) where code == .insufficientLiquidity {
    print("No liquidity: \(message)")
} catch {
    print(error.localizedDescription)
}
```

## Testing Your Integration

Set `useMock: true` to swap in `MockWalletsAPIClient`, which returns deterministic responses without making network calls — ideal for SwiftUI previews and unit tests.

```swift
let client = try WalletsClient(
    config: CDPCoreConfig(projectId: "test", useMock: true)
)
await client.start()
```

For richer fake responses (programmable per-call), implement the `WalletsAPIClient` protocol yourself and inject it via the `apiClient:` parameter on `WalletsClient.init`.

## Documentation

- [Wallet API v2](https://docs.cdp.coinbase.com/wallet-api-v2/docs/welcome)
- [API Reference](https://docs.cdp.coinbase.com/api-v2/docs/welcome)

## License

This project is licensed under the Apache 2.0 License — see the [LICENSE](LICENSE) file for details.

## Support

For feature requests, feedback, or questions, please reach out to us in the **#cdp-sdk** channel of the [Coinbase Developer Platform Discord](https://discord.com/invite/cdp).

- [API Reference](https://docs.cdp.coinbase.com/api-v2/docs/welcome)
- [GitHub Issues](https://github.com/coinbase/cdp-swift/issues)

## Security

If you discover a security vulnerability within this SDK, please see our [Security Policy](https://github.com/coinbase/cdp-swift/blob/main/SECURITY.md) for disclosure information.
