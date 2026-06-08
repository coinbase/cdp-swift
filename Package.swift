// swift-tools-version: 5.9
import PackageDescription

let version = "0.0.0-alpha.5"
let checksum = "e7a3cf07726dff188adec197adc92529f9ee2950ef63eb8cc08f99f1d759506f"

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
