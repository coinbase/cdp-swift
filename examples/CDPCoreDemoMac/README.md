# CDP Wallets Demo (macOS)

macOS version of the CDP Wallets Demo app. Uses the same source files as the iOS
demo (`../CDPCoreDemo/Sources/CDPCoreDemo/`) with platform-specific adaptations via
`#if os(macOS)` guards.

This target exists because the demo relies on Keychain persistence and OAuth via
`ASWebAuthenticationSession`, which require a properly bundled, signed `.app`. The
shared sources in `../CDPCoreDemo` aren't runnable as a standalone app, so use this
Xcode app target to run and verify the demo on macOS.

## Prerequisites

- Xcode 15+
- macOS 13+

## Setup

1. Generate and open the Xcode project:
   ```bash
   xcodegen generate   # if you don't have xcodegen: brew install xcodegen
   open CDPCoreDemoMac.xcodeproj
   ```

2. Configure the app via the **Run** scheme's environment variables
   (Product > Scheme > Edit Scheme > Run > Arguments > Environment Variables).
   For real OAuth sign-in set `CDP_USE_MOCK=false` and a real `CDP_PROJECT_ID`
   (with the provider configured in the CDP dashboard). Leave `CDP_USE_MOCK=true`
   for offline testing of non-OAuth flows.

3. Run the app (the generated `.app` bundle), open **Auth**, and tap **Google** or
   **Apple**. An `ASWebAuthenticationSession` sheet presents on the app window;
   completing sign-in returns automatically and the UI shows the authenticated user.

## OAuth notes

- The CDPCore SDK opens the provider auth page itself via `ASWebAuthenticationSession`
  and captures the redirect internally using `callbackURLScheme`. The `cdpdemo` URL
  scheme is also registered in `SupportingFiles/Info.plist` as a secondary path.
- `CDP_CALLBACK_URL_SCHEME` (default `cdpdemo`) must match the `CFBundleURLSchemes`
  entry in `SupportingFiles/Info.plist`.

## Project Structure

Source files are shared with the iOS/macOS demo
(`../CDPCoreDemo/Sources/CDPCoreDemo/`). The Xcode project references them directly —
no duplication.

## Regenerating the Xcode Project

`project.yml` is the authoritative spec. The generated `.xcodeproj` is committed so
the app can be opened and run without installing XcodeGen.

```bash
brew install xcodegen  # if not installed
xcodegen generate
```

This demo depends on the public [`cdp-swift`](https://github.com/coinbase/cdp-swift)
release (pinned in `project.yml` under `packages.CDPCore`). Xcode resolves it on open.
