// swift-tools-version: 5.9
import PackageDescription

let version = "0.1.1-canary.1"
let checksum = "c93d072f2e9774e2e605f5fc975e7f4615d435be657123800af78d7be3b69c58"

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
