// swift-tools-version: 5.9
import PackageDescription

let version = "0.1.2-alpha.1"
let checksum = "8ac0f272019ec238df8b094b7384993acec29e4667391d33ee6ad5308edc8710"

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
