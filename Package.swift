// swift-tools-version: 5.9
import PackageDescription

let version = "0.0.0-alpha.0"
let checksum = "2e3229aeee198b81eaead9a981abcdfd64b3ccaaac103826a107950c797a33a5"

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
