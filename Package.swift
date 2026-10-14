// swift-tools-version: 5.9
import PackageDescription

let version = "0.1.1"
let checksum = "b326af8fe3fb46c195e221bc6ae1428788d84ac552dd38a32e82f31f20333aa1"

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
