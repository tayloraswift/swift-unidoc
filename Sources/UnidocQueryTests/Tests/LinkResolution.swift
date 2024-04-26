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
                package: "swift-test",
                from: "TestPackages"),
            with: toolchain)

        example.roundtrip(for: tests, in: workspace.path)

        let swift:SymbolGraphObject<Void>
        do
        {
            //  Use the cached binary if available.
            swift = try .load(swift: toolchain.version, in: workspace.path)
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
                    "LinkAnchors.Example-article": [
                        "Example-article#Level two heading",
                        "Example-article#Level two heading: with special characters",
                        "Example-article#Level three heading",
                        "Example-article#Level four heading",
                        "Example-article#Level four heading with hashtag (#)",
                    ],
                ],
                fragmentLinks: [
                    "Using the LinkAnchors enum"
                ]),

            .init(name: "Article",
                path: ["LinkAnchors", "Example-article"],
                //  Both the roundabout link and the direct link should be optimized to a single
                //  direct link.
                fragmentLinks: [
                    "Level two heading",
                ])
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
