# CDP Wallets Demo (iOS)

iOS version of the CDP Wallets Demo app. Uses the same source files as the macOS demo with platform-specific adaptations via `#if os(iOS)` guards.

## Prerequisites

- Xcode 15+
- iOS 16+ simulator or device

## Setup

1. Copy the environment file:
   ```bash
   cp Resources/.env.example Resources/.env
   ```

2. Edit `Resources/.env` with your CDP project configuration (or leave `CDP_USE_MOCK=true` for offline testing).

3. Open `CDPCoreDemoiOS.xcodeproj` in Xcode.

4. Select an iOS simulator or device target and run.

## Project Structure

Source files are shared with the macOS demo (`../CDPCoreDemo/Sources/CDPCoreDemo/`). The Xcode project references them directly — no duplication.

## Regenerating the Xcode Project

If you need to modify the project structure (add/remove source files, change settings):

```bash
brew install xcodegen  # if not installed
xcodegen generate
```

The `project.yml` is the authoritative spec. The generated `.xcodeproj` is committed so the app can be opened and run without installing XcodeGen.

This demo depends on the public [`cdp-swift`](https://github.com/coinbase/cdp-swift) release (pinned in `project.yml` under `packages.CDPCore`). Xcode resolves it on open. If the repository is private, ensure your machine has Git access to `coinbase/cdp-swift`.
