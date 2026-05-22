// swift-tools-version: 5.9
import PackageDescription

let version = "0.1.0"
let checksum = "PLACEHOLDER"

let package = Package(
    name: "CDPCore",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(name: "CDPCore", targets: ["CDPCore"])
    ],
    targets: [
        .binaryTarget(
            name: "CDPCore",
            url: "https://github.com/coinbase/cdp-swift/releases/download/\(version)/CDPCore.xcframework.zip",
            checksum: checksum
        )
    ]
)
