// swift-tools-version: 5.9
import PackageDescription

let version = "0.0.0-alpha.0"
let checksum = "2edd34730a6fc73c92b7bf7ffdcc63e640b8e1e0516ead9e4c1c6b136285c4c3"

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
