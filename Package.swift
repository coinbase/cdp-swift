// swift-tools-version: 5.9
import PackageDescription

let version = "0.0.0-alpha.6"
let checksum = "e1736196abfcc3499b6f70808e331eba14ce859472378baa8e6f367e5948b4f5"

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
