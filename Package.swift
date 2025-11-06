// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MdocDataModel18013",
    defaultLocalization: "en",
	platforms: [.macOS(.v14), .iOS(.v16), .tvOS(.v16), .watchOS(.v10)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MdocDataModel18013",
            targets: ["MdocDataModel18013"]),
    ],
    dependencies: [
        .package(url: "https://github.com/niscy-eudiw/SwiftCBOR.git", from: "0.6.2"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.3"),
    ] + cryptoPD
    ,

    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
			name: "MdocDataModel18013",
            dependencies: [
                "SwiftCBOR",
                .product(name: "Logging", package: "swift-log")
                ] + cryptoTD),
        .testTarget(
            name: "MdocDataModel18013Tests",
            dependencies: ["MdocDataModel18013"], resources: [.process("Resources")]),
    ]
)

#if !canImport(CryptoKit)
 var cryptoPD: [Package.Dependency]{  [ Package.Dependency.package(url: "https://github.com/apple/swift-crypto.git", from: "3.9.0"), ] }
 var cryptoTD: [Target.Dependency]{  [ .product(name: "Crypto", package: "swift-crypto"), ] }
#else
 var cryptoPD: [Package.Dependency] { [] }
 var cryptoTD: [Target.Dependency] { [] }
#endif