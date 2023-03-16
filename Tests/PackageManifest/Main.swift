import JSON
import PackageManifest
import System
import Testing

@main
enum Main:SyncTests
{
    static
    func run(tests:Tests)
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
                    let json:JSON.Object = try .init(parsing: json)
                    let expected:PackageManifest = .init(id: "swift-unidoc",
                        root: "/swift/swift-unidoc",
                        requirements:
                        [
                            .init(id: .macOS, min: .minor(11, 0)),
                        ],
                        dependencies:
                        [
                            .filesystem(.init(id: "swift-json",
                                location: "/swift/swift-json")),
                        ])
                    tests.expect(try .init(json: json) ==? expected)
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
                    let json:JSON.Object = try .init(parsing: json)
                    let expected:PackageManifest = .init(id: "swift-unidoc",
                        root: "/swift/swift-unidoc",
                        dependencies:
                        [
                            .resolvable(.init(id: "swift-json",
                                requirement: .reference(.branch("master")),
                                location: .remote(
                                    url: "https://github.com/kelvin13/swift-json"))),
                            
                            .resolvable(.init(id: "swift-grammar",
                                requirement: .range(.v(0, 3, 1) ..< .v(0, 4, 0)),
                                location: .remote(
                                    url: "https://github.com/kelvin13/swift-grammar"))),
                            
                            .resolvable(.init(id: "swift-hash",
                                requirement: .revision(.init(
                                    "36ef4bf1e6ae38f881ed253d5656839a046456f1")),
                                location: .remote(
                                    url: "https://github.com/kelvin13/swift-hash"))),
                            
                            .resolvable(.init(id: "swift-mongodb",
                                requirement: .range(.v(0, 4, 5) ..< .v(0, 5, 0)),
                                location: .local(
                                    file: "/swift/swift-mongodb"))),
                            
                            .resolvable(.init(id: "swift-system",
                                requirement: .reference(.version(.v(0, 4, 5))),
                                location: .remote(
                                    url: "https://github.com/apple/swift-system"))),
                        ])
                    tests.expect(try .init(json: json) ==? expected)
                }
            }
        }
        if  let tests:TestGroup = tests / "targets"
        {
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
                    let expected:PackageManifest.Target = .init(id: "SymbolAvailability",
                        dependencies:
                        [
                            .target(.init(id: "SemanticVersions", platforms: [.linux])),
                            .target(.init(id: "Symbols")),
                        ])
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
                        "swift-json",
                        null,
                        null
                      ]
                    },
                    {
                      "product" : [
                        "JSONEncoding",
                        "swift-json",
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
                    let expected:PackageManifest.Target = .init(id: "SymbolResolution",
                        dependencies:
                        [
                            .target(.init(id: "Symbols")),

                            .product(.init(id: "JSONDecoding",
                                package: "swift-json")),
                                
                            .product(.init(id: "JSONEncoding",
                                package: "swift-json",
                                platforms: [.linux])),
                        ])
                    tests.expect(try .init(json: json) ==? expected)
                }
            }
        }
        if  let tests:TestGroup = tests / "integration" / "testmodules"
        {
            tests.do
            {
                let filepath:FilePath = "TestModules/Package.swift.json"
                let file:[UInt8] = try filepath.read()
                let json:JSON.Object = try .init(parsing: file)

                let manifest:PackageManifest = try .init(json: json)
                
                tests.expect(manifest.id ==? "swift-unidoc-testmodules")
                tests.expect(manifest.root ==? "/swift/swift-unidoc/TestModules")
            }
        }
    }
}
