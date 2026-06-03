// swift-tools-version: 5.9
import PackageDescription

let version = "0.0.0-alpha.1"
let checksum = "b21b14e6166ac6814cbe2da197577e1618d9c688413b96c1d52bde227baa68be"

let package = Package(
    name: "CDPCore",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        .library(name: "CDPCore", targets: ["CDPCore"]),
    ],
    targets: [
        .binaryTarget(
            name: "CDPCore",
            url: "https://github.com/coinbase/cdp-swift/releases/download/\(version)/CDPCore.xcframework.zip",
            checksum: checksum
        ),
    ]
)
