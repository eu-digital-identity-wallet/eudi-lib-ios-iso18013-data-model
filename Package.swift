// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MdocDataModel18013",
    defaultLocalization: "en",
	platforms: [.macOS(.v12), .iOS(.v13), .watchOS(.v9)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MdocDataModel18013",
            targets: ["MdocDataModel18013"]),
    ],
    dependencies: [ 
        .package(url: "https://github.com/scytales-com/SwiftCBOR.git", from: "0.5.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.3"),
     ],

    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
			name: "MdocDataModel18013", 
            dependencies: [
                "SwiftCBOR",
                .product(name: "Logging", package: "swift-log")
                ]),
        .testTarget(
            name: "MdocDataModel18013Tests",
            dependencies: ["MdocDataModel18013"]),
    ]
)
