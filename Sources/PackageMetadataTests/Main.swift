import JSON
import PackageMetadata
import PackageGraphs
import ModuleGraphs
import System
import Testing

@main
enum Main:SyncTests
{
    static
    func run(tests:Tests)
    {
        if  let tests:TestGroup = tests / "resolutions"
        {
            if  let tests:TestGroup = tests / "local"
            {
                let json:String =
                """
                {
                "pins" : [
                    {
                    "identity" : "swift-json",
                    "kind" : "localSourceControl",
                    "location" : "/swift/swift-json",
                    "state" : {
                        "revision" : "36ef4bf1e6ae38f881ed253d5656839a046456f1",
                        "version" : "0.4.5"
                    }
                    }
                ],
                "version" : 2
                }
                """
                tests.do
                {
                    let resolutions:PackageResolutions = try .init(parsing: json)
                    let expected:[Repository.Pin] =
                    [
                        .init(id: "swift-json",
                            location: .local(root: "/swift/swift-json"),
                            revision: 0x36ef4bf1e6ae38f881ed253d5656839a046456f1,
                            version: .stable(.release(.v(0, 4, 5)))),
                    ]
                    tests.expect(resolutions.version ==? .v2)
                    tests.expect(resolutions.pins ..? expected)
                }
            }
            if  let tests:TestGroup = tests / "remote"
            {
                let json:String =
                """
                {
                "pins" : [
                    {
                    "identity" : "swift-atomics",
                    "kind" : "remoteSourceControl",
                    "location" : "https://github.com/apple/swift-atomics.git",
                    "state" : {
                        "revision" : "ff3d2212b6b093db7f177d0855adbc4ef9c5f036",
                        "version" : "1.0.3"
                    }
                    },
                    {
                    "identity" : "swift-grammar",
                    "kind" : "remoteSourceControl",
                    "location" : "https://github.com/kelvin13/swift-grammar",
                    "state" : {
                        "revision" : "69613825b2ad1d0538c59d72e548867ce7568cc2",
                        "version" : "0.3.1"
                    }
                    }
                ],
                "version" : 2
                }
                """
                tests.do
                {
                    let resolutions:PackageResolutions = try .init(parsing: json)
                    let expected:[Repository.Pin] =
                    [
                        .init(id: "swift-atomics",
                            location: .remote(
                                url: "https://github.com/apple/swift-atomics.git"),
                            revision: 0xff3d2212b6b093db7f177d0855adbc4ef9c5f036,
                            version: .stable(.release(.v(1, 0, 3)))),
                        .init(id: "swift-grammar",
                            location: .remote(
                                url: "https://github.com/kelvin13/swift-grammar"),
                            revision: 0x69613825b2ad1d0538c59d72e548867ce7568cc2,
                            version: .stable(.release(.v(0, 3, 1)))),
                    ]
                    tests.expect(resolutions.version ==? .v2)
                    tests.expect(resolutions.pins ..? expected)
                }
            }
            if  let tests:TestGroup = tests / "dogfood"
            {
                tests.do
                {
                    let filepath:FilePath = "Package.resolved"
                    let file:[UInt8] = try filepath.read()
                    let json:JSON.Object = try .init(parsing: file)

                    let _:PackageResolutions = try .init(json: json)
                }
            }
            if  let tests:TestGroup = tests / "legacy"
            {
                let json:String =
                """
                {
                  "object": {
                    "pins": [
                      {
                        "package": "swift-argument-parser",
                        "repositoryURL": "https://github.com/apple/swift-argument-parser.git",
                        "state": {
                          "branch": null,
                          "revision": "fee6933f37fde9a5e12a1e4aeaa93fe60116ff2a",
                          "version": "1.2.2"
                        }
                      }
                    ]
                  },
                  "version": 1
                }
                """
                tests.do
                {
                    let resolutions:PackageResolutions = try .init(parsing: json)
                    let expected:[Repository.Pin] =
                    [
                        .init(id: "swift-argument-parser",
                            location: .remote(
                                url: "https://github.com/apple/swift-argument-parser.git"),
                            revision: 0xfee6933f37fde9a5e12a1e4aeaa93fe60116ff2a,
                            version: .stable(.release(.v(1, 2, 2)))),
                    ]
                    tests.expect(resolutions.version ==? .v1)
                    tests.expect(resolutions.pins ..? expected)
                }
            }
        }

        if  let tests:TestGroup = tests / "manifests"
        {
            if  let tests:TestGroup = tests / "dependencies"
            {
                if  let tests:TestGroup = tests / "filesystem"
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
                        let expected:PackageManifest = .init(name: "swift-unidoc",
                            root: "/swift/swift-unidoc",
                            requirements:
                            [
                                .init(id: .macOS, min: .minor(.v(11, 0))),
                            ],
                            dependencies:
                            [
                                .filesystem(.init(id: "swift-json",
                                    location: "/swift/swift-json")),
                            ],
                            format: .v(5, 7, 0))
                        tests.expect(try .init(parsing: json) ==? expected)
                    }
                }
                if  let tests:TestGroup = tests / "repository"
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
                                                "https://github.com/kelvin13/swift-json"
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
                                                "https://github.com/kelvin13/swift-grammar"
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
                                                "https://github.com/kelvin13/swift-hash"
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
                        let expected:PackageManifest = .init(name: "swift-unidoc",
                            root: "/swift/swift-unidoc",
                            dependencies:
                            [
                                .resolvable(.init(id: "swift-json",
                                    requirement: .refname("master"),
                                    location: .remote(
                                        url: "https://github.com/kelvin13/swift-json"))),

                                .resolvable(.init(id: "swift-grammar",
                                    requirement: .stable(.range(.v(0, 3, 1) ..< .v(0, 4, 0))),
                                    location: .remote(
                                        url: "https://github.com/kelvin13/swift-grammar"))),

                                .resolvable(.init(id: "swift-hash",
                                    requirement: .revision(
                                        0x36ef4bf1e6ae38f881ed253d5656839a046456f1),
                                    location: .remote(
                                        url: "https://github.com/kelvin13/swift-hash"))),

                                .resolvable(.init(id: "swift-mongodb",
                                    requirement: .stable(.range(.v(0, 4, 5) ..< .v(0, 5, 0))),
                                    location: .local(
                                        root: "/swift/swift-mongodb"))),

                                .resolvable(.init(id: "swift-system",
                                    requirement: .stable(.exact(.v(0, 4, 5))),
                                    location: .remote(
                                        url: "https://github.com/apple/swift-system"))),
                            ],
                            format: .v(5, 7, 0))
                        tests.expect(try .init(parsing: json) ==? expected)
                    }
                }
            }
            if  let tests:TestGroup = tests / "targets"
            {
                if  let tests:TestGroup = tests / "literal-dependencies"
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
                            dependencies: .init(targets:
                            [
                                .init(id: "SwiftBasicFormat"),
                                .init(id: "SwiftSyntax"),
                                .init(id: "SwiftSyntaxBuilder"),
                            ]))
                        tests.expect(try .init(json: json) ==? expected)
                    }
                }
                if  let tests:TestGroup = tests / "target-dependencies"
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
                if  let tests:TestGroup = tests / "product-dependencies"
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
            if  let tests:TestGroup = tests / "integration" / "testmodules"
            {
                tests.do
                {
                    let filepath:FilePath = "TestModules/Package.swift.json"
                    let manifest:PackageManifest = try .init(parsing: try filepath.read())

                    tests.expect(manifest.name ==? "swift-unidoc-testmodules")
                    tests.expect(manifest.root ==? "/swift/swift-unidoc/TestModules")
                }
            }
        }
    }
}
