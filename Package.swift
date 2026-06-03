// swift-tools-version: 5.9
import PackageDescription

let version = "0.0.0-alpha.0"
let checksum = "615edd24115b9388eeed4bd8b06d6b1bea025aa6c8127f740e7a0f41961ef4f0"

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
