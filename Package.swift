// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-sfomuseum-logger",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SFOMuseumLogger",
            targets: ["SFOMuseumLogger"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.3")
    ],
    targets: [
        .target(
            name: "SFOMuseumLogger",
            dependencies: [
                .product(name: "Logging", package: "swift-log")
            ]
        ),
        .executableTarget(
            name: "sfomuseum-logger",
            dependencies: [
                "SFOMuseumLogger",
                .product(name: "ArgumentParser", package: "swift-argument-parser")  
            ],
            path: "Scripts"
        )
    ]    
)
