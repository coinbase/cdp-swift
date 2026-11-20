// swift-tools-version: 5.9
import PackageDescription

let version = "0.1.2-alpha.0"
let checksum = "6852a78ff8ef087ad4ffb290f946ba9e84ec6e660388731d300d1ca43d59b019"

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
