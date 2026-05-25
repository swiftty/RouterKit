// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RouterKit",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "RouterKit",
            targets: ["RouterKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftty/swift-project-starter", from: "0.3.0"),
        // AUTO GENERATED ↓: swift-project-starter: deps
        .package(url: "https://github.com/swiftty/swift-format-plugin", from: "1.0.0")
        // AUTO GENERATED ↑: swift-project-starter: deps
    ],
    targets: [
        .target(
            name: "RouterKit"),
        .testTarget(
            name: "RouterKitTests",
            dependencies: ["RouterKit"]),
    ]
)

// AUTO GENERATED ↓: swift-project-starter: settings
for target in package.targets {
    if [.executable, .test, .regular].contains(target.type) {
        target.swiftSettings = (target.swiftSettings ?? []) + [
            .enableUpcomingFeature("InternalImportsByDefault"),
            .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
            .enableUpcomingFeature("MemberImportVisibility"),
            .enableUpcomingFeature("InferIsolatedConformances"),
            .enableUpcomingFeature("ImmutableWeakCaptures"),
            .enableUpcomingFeature("ExistentialAny")
        ]
        target.plugins = (target.plugins ?? []) + [
            .plugin(name: "Lint", package: "swift-format-plugin")
        ]
    }
}
// AUTO GENERATED ↑: swift-project-starter: settings
