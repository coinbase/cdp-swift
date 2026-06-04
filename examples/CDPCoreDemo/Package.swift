// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CDPCoreDemo",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    dependencies: [
        .package(url: "https://github.com/coinbase/cdp-swift", exact: "0.0.0-alpha.3"),
    ],
    targets: [
        .executableTarget(
            name: "CDPCoreDemo",
            dependencies: [
                .product(name: "CDPCore", package: "cdp-swift"),
            ],
            path: "Sources/CDPCoreDemo",
            exclude: ["Info.plist"],
            resources: [
                .copy("Resources/.env"),
            ],
            linkerSettings: [
                // Embed Info.plist in the Mach-O binary's __TEXT segment so
                // CoreFoundation reads it at dyld load time (before main).
                // Required for iOS Simulator since SPM executables lack .app bundles.
                .unsafeFlags([
                    "-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__info_plist",
                    "-Xlinker", "Sources/CDPCoreDemo/Info.plist",
                ], .when(platforms: [.iOS])),
            ]
        ),
    ]
)
