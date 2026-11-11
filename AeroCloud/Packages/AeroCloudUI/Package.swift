// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AeroCloudUI",
    platforms: [.iOS("27.0")],
    products: [
        .library(name: "AeroCloudUI", targets: ["AeroCloudUI"])
    ],
    dependencies: [
        .package(path: "../AeroCloudCore")
    ],
    targets: [
        .target(
            name: "AeroCloudUI",
            dependencies: [
                .product(name: "AeroCloudCore", package: "AeroCloudCore")
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
