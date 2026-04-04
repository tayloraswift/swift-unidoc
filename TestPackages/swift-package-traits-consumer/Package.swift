// swift-tools-version:6.1
import PackageDescription

let package: Package = .init(
    name: "swift-package-traits-consumer",
    products: [
    ],
    traits: [
        .trait(name: "RSA"),
    ],
    dependencies: [
        .package(
            path: "../swift-package-traits",
            traits: [
                .trait(name: "Cryptography", condition: .when(traits: ["RSA"]))
            ]
        ),
    ],
    targets: [
        .target(name: "B"),
    ]
)
