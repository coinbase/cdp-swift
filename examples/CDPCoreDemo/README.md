# CDPCoreDemo

A multiplatform SwiftUI example app demonstrating the full CDPCore SDK.

This example depends on the public [`cdp-swift`](https://github.com/coinbase/cdp-swift)
release (pinned in `Package.swift`). SwiftPM resolves it automatically on build. If
the repository is private, ensure your machine has Git access to `coinbase/cdp-swift`.

## Requirements

- iOS 16+ / macOS 13+
- Xcode 15+
- Swift 5.9+

## Setup

Configuration is read from the process environment. Set the variables on the
**Run** scheme in Xcode:

1. Open `Package.swift` in Xcode
2. Product > Scheme > Edit Scheme (or `Cmd+<`)
3. Select **Run** > **Arguments** tab > **Environment Variables**
4. Add:
   - `CDP_PROJECT_ID` = your project ID
   - `CDP_USE_MOCK` = `true` (for offline testing)
   - `CDP_BASE_PATH` (optional, override API URL)
   - `CDP_ETHEREUM_CREATE_ON_LOGIN` = `smart` or `eoa` (optional)
   - `CDP_SOLANA_CREATE_ON_LOGIN` = `true` (optional)

## Run

```bash
# Build
swift build

# Run from the terminal (export the variables above in your shell first)
swift run

# Or open in Xcode and set the variables on the Run scheme
open Package.swift
```

## iOS Simulator Tips

### Enabling keyboard input

By default the iOS Simulator shows an on-screen software keyboard. To type using your Mac keyboard instead:

1. Click the Simulator window so its menu bar is active (you should see **Simulator** in the top-left of the menu bar, not **Xcode**)
2. Use the keyboard shortcut **`Cmd+Shift+K`** to toggle "Connect Hardware Keyboard"

Alternatively, find the toggle in the Simulator menu bar:
- **Xcode 16+**: Edit > Keyboard > Connect Hardware Keyboard
- **Xcode 15 and earlier**: I/O > Keyboard > Connect Hardware Keyboard

When hardware keyboard is connected, the on-screen keyboard won't appear — tap a text field and type directly from your Mac keyboard. Press `Cmd+K` to manually show/hide the software keyboard if needed.

## Features

| Section | Operations |
|---------|-----------|
| **Auth** | Email OTP, SMS OTP, OAuth (Google/Apple), Link accounts |
| **Accounts** | Create EVM EOA, EVM Smart Account, Solana accounts |
| **EVM** | Sign message/hash/transaction, send transaction, user operations |
| **Solana** | Sign message/transaction, send transaction |
| **Swap** | Get price, execute token swaps |
| **MFA** | Get config, initiate/submit/cancel verification |
| **Export** | Export EVM and Solana private keys |
| **Delegation** | Create, view, revoke delegations |
| **Spend Permissions** | Create, list, revoke spend permissions |

## Architecture

- **App/** — Entry point, SDK initialization, configuration
- **Navigation/** — Platform-adaptive navigation (TabView on iOS, NavigationSplitView on macOS)
- **Features/** — Feature modules with View + ViewModel pairs
- **Shared/** — Reusable components, extensions, and modifiers

Each feature follows MVVM with `ObservableObject` ViewModels using async/await for SDK calls.
