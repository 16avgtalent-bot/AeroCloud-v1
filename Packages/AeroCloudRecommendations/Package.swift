// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AeroCloudRecommendations",
    platforms: [.iOS("27.0")],
    products: [
        .library(name: "AeroCloudRecommendations", targets: ["AeroCloudRecommendations"])
    ],
    targets: [
        .target(name: "AeroCloudRecommendations")
    ],
    swiftLanguageModes: [.v6]
)
