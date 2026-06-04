// swift-tools-version: 5.9
import PackageDescription

let version = "0.0.0-alpha.3"
let checksum = "0090f9753239cdcf7c34758a023f15b022c5222d7d64423fa0d1d4faa19ca1e8"

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
