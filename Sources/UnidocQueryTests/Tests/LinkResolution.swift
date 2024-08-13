import MongoDB
import MongoTesting
import SymbolGraphBuilder
import SymbolGraphs
@_spi(testable)
import UnidocDB

struct LinkResolution:UnidocDatabaseTestBattery
{
    typealias Configuration = Main.Configuration

    static
    func run(tests:TestGroup,
        pool:Mongo.SessionPool,
        unidoc:Unidoc.DB) async throws
    {
        let workspace:SSGC.Workspace = try .create(at: ".testing")
        let toolchain:SSGC.Toolchain = try .detect(pretty: true)

        let example:SymbolGraphObject<Void> = try workspace.build(package: .local(
                project: "swift-test",
                among: "TestPackages"),
            with: toolchain)

        example.roundtrip(for: tests, in: workspace.location)

        let swift:SymbolGraphObject<Void>
        do
        {
            //  Use the cached binary if available.
            swift = try .load(swift: toolchain.version, in: workspace.location)
        }
        catch
        {
            swift = try workspace.build(special: .swift, with: toolchain)
        }

        let session:Mongo.Session = try await .init(from: pool)

        tests.expect(try await unidoc.store(linking: swift, with: session).0 ==? .init(
            edition: .init(package: 0, version: 0),
            updated: false))

        tests.expect(try await unidoc.store(linking: example, with: session).0 ==? .init(
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
                        //  TODO:
                        //  This is not a bug, but it is a missed optimization opportunity. We
                        //  do not need to resolve the two leading path components, as they will
                        //  never be shown to the user.
                        "swift string index",
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
                try await `case`.run(tests: tests, session: session, unidoc: unidoc)
            }
        }
    }
}
