// swift-tools-version: 5.9
import PackageDescription

let version = "0.0.0-alpha.5"
let checksum = "2f04baec6b7d58d8076ba261e93228a7de4ad3fb0cf5b98ac7de00f7083006c0"

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
