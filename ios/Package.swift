// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "star_micronics_printer",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(name: "star-micronics-printer", targets: ["star_micronics_printer"])
    ],
    dependencies: [
        .package(url: "https://github.com/star-micronics/StarXpand-SDK-iOS", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "star_micronics_printer",
            dependencies: [
                .product(name: "StarIO10", package: "StarXpand-SDK-iOS")
            ],
            path: "Classes"
        )
    ]
)
