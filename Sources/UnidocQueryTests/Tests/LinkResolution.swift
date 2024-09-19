import MongoDB
import MongoTesting
import SymbolGraphBuilder
import SymbolGraphs
import System_
@_spi(testable)
import UnidocDB

struct LinkResolution:UnidocDatabaseTestBattery
{
    typealias Configuration = Main.Configuration

    static
    func run(tests:TestGroup,
        db:Unidoc.DB) async throws
    {
        let workspace:SSGC.Workspace = try .create(at: ".testing")
        let toolchain:SSGC.Toolchain = try .detect(pretty: true)

        let example:SymbolGraphObject<Void> = try workspace.build(
            package: .local(project: "TestPackages" / "swift-test"),
            with: toolchain)

        example.roundtrip(for: tests, in: workspace.location)

        let swift:SymbolGraphObject<Void>
        do
        {
            //  Use the cached binary if available.
            swift = try .load(swift: toolchain.splash.swift, in: workspace.location)
        }
        catch
        {
            swift = try workspace.build(special: .swift, with: toolchain)
        }

        tests.expect(try await db.store(linking: swift).0 ==? .init(
            edition: .init(package: 0, version: 0),
            updated: false))

        tests.expect(try await db.store(linking: example).0 ==? .init(
            edition: .init(package: 1, version: -1),
            updated: false))

        let cases:[TestCase] =
        [
            .init(name: "Decl",
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
                ]),

            .init(name: "InternalLinks",
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
                ]),

            .init(name: "ExternalLinks",
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
                outlines: 4),
        ]

        for `case`:TestCase in cases
        {
            guard
            let tests:TestGroup = tests / `case`.name
            else
            {
                continue
            }

            await tests.do
            {
                try await `case`.run(tests: tests, db: db)
            }
        }
    }
}
