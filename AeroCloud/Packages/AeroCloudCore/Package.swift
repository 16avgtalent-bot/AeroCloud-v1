// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AeroCloudCore",
    platforms: [
        .iOS("27.0")
    ],
    products: [
        .library(name: "AeroCloudCore", targets: ["AeroCloudCore"])
    ],
    targets: [
        .target(name: "AeroCloudCore"),
        .testTarget(name: "AeroCloudCoreTests", dependencies: ["AeroCloudCore"])
    ],
    swiftLanguageModes: [.v6]
)
