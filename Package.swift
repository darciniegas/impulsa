// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "impulsa",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(name: "impulsa", targets: ["impulsa"]),
    ],
    targets: [
        .target(name: "impulsa"),
    ]
)
