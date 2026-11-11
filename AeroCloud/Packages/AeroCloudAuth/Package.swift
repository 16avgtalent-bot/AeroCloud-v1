// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AeroCloudAuth",
    platforms: [.iOS("27.0")],
    products: [
        .library(name: "AeroCloudAuth", targets: ["AeroCloudAuth"])
    ],
    targets: [
        .target(name: "AeroCloudAuth")
    ],
    swiftLanguageModes: [.v6]
)
