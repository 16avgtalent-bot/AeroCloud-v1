// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AeroCloudProviders",
    platforms: [.iOS("27.0")],
    products: [
        .library(name: "AeroCloudProviders", targets: ["AeroCloudProviders"])
    ],
    targets: [
        .target(name: "AeroCloudProviders")
    ],
    swiftLanguageModes: [.v6]
)
