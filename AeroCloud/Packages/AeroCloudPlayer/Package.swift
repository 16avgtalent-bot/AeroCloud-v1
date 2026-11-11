// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AeroCloudPlayer",
    platforms: [.iOS("27.0")],
    products: [
        .library(name: "AeroCloudPlayer", targets: ["AeroCloudPlayer"])
    ],
    targets: [
        .target(name: "AeroCloudPlayer")
    ],
    swiftLanguageModes: [.v6]
)
