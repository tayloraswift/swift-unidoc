// swift-tools-version:6.1
import PackageDescription

let package: Package = .init(
    name: "swift-package-traits",
    products: [
    ],
    traits: [
        .trait(name: "Cryptography"),
    ],
    targets: [
        .target(name: "A"),
    ]
)
