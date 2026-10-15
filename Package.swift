// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "StudioKit",
    defaultLocalization: "en",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "StudioKit", targets: ["StudioKit"]),
    ],
    targets: [
        .target(
            name: "StudioKit",
            resources: [.process("Resources")]
        ),
    ]
)
