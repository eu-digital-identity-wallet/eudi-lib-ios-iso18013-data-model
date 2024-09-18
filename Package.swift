// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MdocDataModel18013",
    defaultLocalization: "en",
	platforms: [.macOS(.v10_15), .iOS(.v14), .tvOS(.v12), .watchOS(.v9)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MdocDataModel18013",
            targets: ["MdocDataModel18013"]),
    ],
    dependencies: [ 
        .package(url: "https://github.com/niscy-eudiw/SwiftCBOR.git", from: "0.6.2"),
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
            dependencies: ["MdocDataModel18013"], resources: [.process("Resources")]),
    ]
)
