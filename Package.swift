// swift-tools-version: 5.9
import PackageDescription

let version = "0.0.0-alpha.0"
let checksum = "2fa84057930556017e614342147ed3fa89cc401f32a838b296fd4e78441e3085"

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
