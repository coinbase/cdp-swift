// swift-tools-version: 5.9
import PackageDescription

let version = "0.2.0"
let checksum = "9e84d57d6ec4099cce18438446246be5c041b43538e55454dc719b99270b1c99"

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
