// swift-tools-version: 5.9
import PackageDescription

let version = "0.0.0-alpha.4"
let checksum = "0106a0de009a2efbc85d87a681858bb36a12126ec05b9f077b4171d3f3ac88c9"

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
