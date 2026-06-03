// swift-tools-version: 5.9
import PackageDescription

let version = "0.0.0-alpha.2"
let checksum = "378115aafad0b1897468367023eaad0cb9b64dbd13442d4093aba0a50db6f56c"

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
