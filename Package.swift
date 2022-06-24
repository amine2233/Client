// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "Client",
    platforms: [.iOS(.v15), .macOS(.v12), .watchOS(.v8), .tvOS(.v15)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Client",
            targets: ["Client"]),
        .library(
            name: "Reachability",
            targets: ["Reachability"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Client",
            dependencies: []),
        .testTarget(
            name: "ClientTests",
            dependencies: ["Client"]),
        .target(
            name: "Reachability",
            dependencies: []),
        .testTarget(
            name: "ReachabilityTests",
            dependencies: ["Reachability"])
    ]
)
