import JSON
import PackageGraphs
import PackageMetadata
import System_
import Testing_

extension Main
{
    enum PackageSwift
    {
    }
}
extension Main.PackageSwift:TestBattery
{
    static
    func run(tests:TestGroup)
    {
        if  let tests:TestGroup = tests / "FilesystemDependencies"
        {
            let json:String =
            """
            {
                "cLanguageStandard" : null,
                "cxxLanguageStandard" : null,
                "dependencies" : [
                    {
                        "fileSystem" : [
                            {
                                "identity" : "swift-json",
                                "path" : "/swift/swift-json",
                                "productFilter" : null
                            }
                        ]
                    }
                ],
                "name" : "swift-unidoc",
                "packageKind" : {
                    "root" : [
                        "/swift/swift-unidoc"
                    ]
                },
                "pkgConfig" : null,
                "platforms" : [
                    {
                        "options" : [

                        ],
                        "platformName" : "macos",
                        "version" : "11.0"
                    }
                ],
                "products" : [],
                "providers" : null,
                "swiftLanguageVersions" : null,
                "targets" : [],
                "toolsVersion" : {
                    "_version" : "5.7.0"
                }
            }
            """
            tests.do
            {
                let expected:SPM.Manifest = .init(name: "swift-unidoc",
                    root: "/swift/swift-unidoc",
                    requirements:
                    [
                        .init(id: .macOS, min: .minor(.v(11, 0))),
                    ],
                    dependencies:
                    [
                        .filesystem(.init(
                            identity: "swift-json",
                            location: "/swift/swift-json")),
                    ],
                    format: .v(5, 7, 0))
                tests.expect(try .init(parsing: json) ==? expected)
            }
        }
        if  let tests:TestGroup = tests / "RepositoryDependencies"
        {
            let json:String =
            """
            {
                "cLanguageStandard" : null,
                "cxxLanguageStandard" : null,
                "dependencies" : [
                    {
                        "sourceControl" : [
                            {
                                "identity" : "swift-json",
                                "location" : {
                                    "remote" : [
                                        "https://github.com/tayloraswift/swift-json"
                                    ]
                                },
                                "productFilter" : null,
                                "requirement" : {
                                    "branch" : [
                                        "master"
                                    ]
                                }
                            }
                        ]
                    },
                    {
                        "sourceControl" : [
                            {
                                "identity" : "swift-grammar",
                                "location" : {
                                    "remote" : [
                                        "https://github.com/tayloraswift/swift-grammar"
                                    ]
                                },
                                "productFilter" : null,
                                "requirement" : {
                                    "range" : [
                                        {
                                            "lowerBound" : "0.3.1",
                                            "upperBound" : "0.4.0"
                                        }
                                    ]
                                }
                            }
                        ]
                    },
                    {
                        "sourceControl" : [
                            {
                                "identity" : "swift-hash",
                                "location" : {
                                    "remote" : [
                                        "https://github.com/tayloraswift/swift-hash"
                                    ]
                                },
                                "productFilter" : null,
                                "requirement" : {
                                    "revision" : [
                                        "36ef4bf1e6ae38f881ed253d5656839a046456f1"
                                    ]
                                }
                            }
                        ]
                    },
                    {
                        "sourceControl" : [
                            {
                                "identity" : "swift-mongodb",
                                "location" : {
                                    "local" : [
                                        "/swift/swift-mongodb"
                                    ]
                                },
                                "productFilter" : null,
                                "requirement" : {
                                    "range" : [
                                        {
                                            "lowerBound" : "0.4.5",
                                            "upperBound" : "0.5.0"
                                        }
                                    ]
                                }
                            }
                        ]
                    },
                    {
                        "sourceControl" : [
                            {
                                "identity" : "swift-system",
                                "location" : {
                                    "remote" : [
                                        "https://github.com/apple/swift-system"
                                    ]
                                },
                                "productFilter" : null,
                                "requirement" : {
                                    "exact" : [
                                        "0.4.5"
                                    ]
                                }
                            }
                        ]
                    }
                ],
                "name" : "swift-unidoc",
                "packageKind" : {
                    "root" : [
                        "/swift/swift-unidoc"
                    ]
                },
                "pkgConfig" : null,
                "platforms" : [],
                "products" : [],
                "providers" : null,
                "swiftLanguageVersions" : null,
                "targets" : [],
                "toolsVersion" : {
                    "_version" : "5.7.0"
                }
            }
            """
            tests.do
            {
                let expected:SPM.Manifest = .init(name: "swift-unidoc",
                    root: "/swift/swift-unidoc",
                    dependencies: [
                        .resolvable(.init(
                            identity: "swift-json",
                            location: .remote(
                                url: "https://github.com/tayloraswift/swift-json"),
                            requirement: .refname("master"))),

                        .resolvable(.init(
                            identity: "swift-grammar",
                            location: .remote(
                                url: "https://github.com/tayloraswift/swift-grammar"),
                            requirement: .stable(.range(.release(.v(0, 3, 1)),
                                to: .release(.v(0, 4, 0)))))),

                        .resolvable(.init(
                            identity: "swift-hash",
                            location: .remote(
                                url: "https://github.com/tayloraswift/swift-hash"),
                            requirement: .revision(
                                0x36ef4bf1e6ae38f881ed253d5656839a046456f1))),

                        .resolvable(.init(
                            identity: "swift-mongodb",
                            location: .local(
                                root: "/swift/swift-mongodb"),
                            requirement: .stable(.range(.release(.v(0, 4, 5)),
                                to: .release(.v(0, 5, 0)))))),

                        .resolvable(.init(
                            identity: "swift-system",
                            location: .remote(
                                url: "https://github.com/apple/swift-system"),
                            requirement: .stable(.exact(.release(.v(0, 4, 5)))))),
                    ],
                    format: .v(5, 7, 0))
                tests.expect(try .init(parsing: json) ==? expected)
            }
        }
        if  let tests:TestGroup = tests / "Targets"
        {
            if  let tests:TestGroup = tests / "LiteralDependencies"
            {
                let json:String =
                """
                {
                "dependencies" : [
                    {
                    "byName" : [
                        "SwiftBasicFormat",
                        null
                    ]
                    },
                    {
                    "byName" : [
                        "SwiftSyntax",
                        null
                    ]
                    },
                    {
                    "byName" : [
                        "SwiftSyntaxBuilder",
                        null
                    ]
                    }
                ],
                "exclude" : [

                ],
                "name" : "SwiftSyntax",
                "resources" : [

                ],
                "settings" : [

                ],
                "type" : "regular"
                }
                """
                tests.do
                {
                    let json:JSON.Object = try .init(parsing: json)
                    let expected:TargetNode = .init(name: "SwiftSyntax",
                        dependencies: .init(nominal:
                        [
                            .init(id: "SwiftBasicFormat"),
                            .init(id: "SwiftSyntax"),
                            .init(id: "SwiftSyntaxBuilder"),
                        ]))
                    tests.expect(try .init(json: json) ==? expected)
                }
            }
            if  let tests:TestGroup = tests / "TargetDependencies"
            {
                let json:String =
                """
                {
                "dependencies" : [
                    {
                    "target" : [
                        "SemanticVersions",
                        {
                        "platformNames" : [
                            "linux"
                        ]
                        }
                    ]
                    },
                    {
                    "target" : [
                        "Symbols",
                        null
                    ]
                    }
                ],
                "exclude" : [

                ],
                "name" : "SymbolAvailability",
                "resources" : [

                ],
                "settings" : [

                ],
                "type" : "regular"
                }
                """
                tests.do
                {
                    let json:JSON.Object = try .init(parsing: json)
                    let expected:TargetNode = .init(name: "SymbolAvailability",
                        dependencies: .init(targets:
                        [
                            .init(id: "SemanticVersions", platforms: [.linux]),
                            .init(id: "Symbols"),
                        ]))
                    tests.expect(try .init(json: json) ==? expected)
                }
            }
            if  let tests:TestGroup = tests / "ProductDependencies"
            {
                let json:String =
                """
                {
                "dependencies" : [
                    {
                    "target" : [
                        "Symbols",
                        null
                    ]
                    },
                    {
                    "product" : [
                        "JSONDecoding",
                        "json",
                        null,
                        null
                    ]
                    },
                    {
                    "product" : [
                        "JSONEncoding",
                        "json",
                        {
                        "_Foo" : "_Bar"
                        },
                        {
                        "platformNames" : [
                            "linux"
                        ]
                        }
                    ]
                    }
                ],
                "exclude" : [

                ],
                "name" : "SymbolResolution",
                "resources" : [

                ],
                "settings" : [

                ],
                "type" : "regular"
                }
                """
                tests.do
                {
                    let json:JSON.Object = try .init(parsing: json)
                    let expected:TargetNode = .init(name: "SymbolResolution",
                        dependencies: .init(
                            products:
                            [
                                .init(id: .init(name: "JSONDecoding", package: "json")),

                                .init(id: .init(name: "JSONEncoding", package: "json"),
                                    platforms: [.linux]),
                            ],
                            targets:
                            [
                                .init(id: "Symbols"),
                            ]))
                    tests.expect(try .init(json: json) ==? expected)
                }
            }
        }
        if  let tests:TestGroup = tests / "Integration" / "TestModules"
        {
            tests.do
            {
                let filepath:FilePath = "TestModules/Package.swift.json"
                let manifest:SPM.Manifest = try .init(parsing: try filepath.read())

                tests.expect(manifest.name ==? "swift-unidoc-testmodules")
                tests.expect(manifest.root ==? "/swift/swift-unidoc/TestModules")
            }
        }
    }
}
