// swift-tools-version: 5.9
import PackageDescription

let version = "0.1.1-canary.0"
let checksum = "c9657075f404561801718cff51db879e17b508e468c5177fe83bb525d23f9b1f"

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
