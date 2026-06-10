// swift-tools-version: 5.9
import PackageDescription

let version = "0.0.0-alpha.7"
let checksum = "00a9bdddb8f3445987a396b6517a42f4a6b5f717c6b97b609fe78ae3ba429ce5"

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
