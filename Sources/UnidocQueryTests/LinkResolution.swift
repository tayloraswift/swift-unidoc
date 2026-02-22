import MongoDB
import SymbolGraphTesting
import SymbolGraphs
import SystemIO
import Testing
@_spi(testable) import UnidocDB
import UnidocTesting

@Suite struct LinkResolution: Unidoc.TestBattery {
    @Test func linkResolution() async throws {
        try await self.run(in: "LinkResolution")
    }

    func run(with db: Unidoc.DB) async throws {
        let directory: FilePath.Directory = "TestPackages"

        //  Use pre-built symbol graphs for speed.
        let example: SymbolGraphObject<Void> = try .load(package: "swift-test", in: directory)
        try example.roundtrip(in: directory)

        let swift: SymbolGraphObject<Void> = try .load(package: .swift, in: directory)

        #expect(
            try await db.store(linking: swift).0 == .init(
                edition: .init(package: 0, version: 0),
                updated: false
            )
        )

        #expect(
            try await db.store(linking: example).0 == .init(
                edition: .init(package: 1, version: -1),
                updated: false
            )
        )

        let cases: [TestCase] = [
            .init(
                name: "Decl",
                path: ["LinkAnchors", "LinkAnchors"],
                internalLinks: [
                    "LinkAnchors.Internal-links": [
                        "Internal-links#Level two heading",
                        "Internal-links#Level two heading: with special characters",
                        "Internal-links#Level three heading",
                        "Internal-links#Level four heading",
                        "Internal-links#Level four heading with hashtag (#)",
                    ],

                    "LinkAnchors.LinkAnchors": [
                        //  This is a known bug:
                        //  https://github.com/tayloraswift/swift-unidoc/issues/196

                        "LinkAnchors",
                        //"LinkAnchors#Using the LinkAnchors enum",
                    ],

                    "LinkAnchors.LinkAnchors.a": [
                        "LinkAnchors a",
                    ],
                ],
                fragmentLinks: [
                    "Using the LinkAnchors enum",
                    "Contributing"
                ]
            ),

            .init(
                name: "InternalLinks",
                path: ["LinkAnchors", "Internal-links"],
                internalLinks: [
                    "LinkAnchors.Internal-links": [
                        "Internal-links",
                    ],
                ],
                //  Both the roundabout link and the direct link should be optimized to a single
                //  direct link.
                fragmentLinks: [
                    "Level two heading",
                ]
            ),

            .init(
                name: "ExternalLinks",
                path: ["LinkAnchors", "External-links"],
                //  Both the roundabout link and the direct link should be optimized to a single
                //  direct link.
                internalLinks: [
                    "Swift.String.Index": [
                        "__attribute",
                    ],
                ],
                externalLinks: [
                    "https://en.wikipedia.org/wiki/Main_Page": true,
                    "https://liberationnews.org": false,
                ],
                //  Note: the duplicate outline was not optimized away because external
                //  links are resolved dynamically, and this means their representation
                //  within symbol graphs encodes their source locations, for diagnostics.
                outlines: 4
            ),
        ]

        for test: TestCase in cases {
            try await test.run(in: db)
        }
    }
}
