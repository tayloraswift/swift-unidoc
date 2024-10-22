import MongoDB
import MongoTesting
import SymbolGraphBuilder
import SymbolGraphs
import SymbolGraphTesting
import Symbols
import Unidoc
@_spi(testable)
import UnidocDB
import UnidocQueries
import UnidocRecords

struct VolumeQueries:UnidocDatabaseTestBattery
{
    typealias Configuration = Main.Configuration

    static
    func run(tests:TestGroup, db:Unidoc.DB) async throws
    {
        let workspace:SSGC.Workspace = try .create(at: ".testing")
        let swift:SSGC.Toolchain = try .detect()

        let package:Symbol.Package = "swift-version-controlled"

        for (i, tag):(Int32, String) in zip(0..., ["0.1.0", "0.2.0", "1.0.0-beta.1"])
        {
            let empty:SymbolGraphObject<Void> = .init(metadata: .init(
                    package: .init(name: package),
                    commit: .init(name: tag),
                    triple: swift.splash.triple,
                    swift: swift.splash.swift),
                graph: .init(modules: []))

            empty.roundtrip(for: tests, in: workspace.location)

            let v:Unidoc.Version = .init(rawValue: i)
            tests.expect(try await db.store(linking: empty).0 ==? .init(
                edition: .init(package: 0, version: v),
                updated: false))
        }

        /// We should be able to resolve version 0.2.0 with a symbolic patch query.
        if  let tests:TestGroup = tests / "LatestRelease"
        {
            let query:Unidoc.VertexQuery<Unidoc.LookupAdjacent> = .init("\(package)", [])
            await tests.do
            {
                if  let output:Unidoc.VertexOutput = tests.expect(
                        value: try await db.query(with: query))
                {
                    tests.expect(output.canonicalVolume?.patch ==? .v(0, 2, 0))
                    tests.expect(output.principalVolume.patch ==? .v(0, 2, 0))
                    tests.expect(value: output.principalVertex?.landing)
                }
            }
        }
        /// We should be able to resolve version 0.2.0 with a symbolic volume query.
        if  let tests:TestGroup = tests / "CurrentRelease"
        {
            let query:Unidoc.VertexQuery<Unidoc.LookupAdjacent> = .init(
                "\(package):0.2.0", [])
            await tests.do
            {
                if  let output:Unidoc.VertexOutput = tests.expect(
                        value: try await db.query(with: query))
                {
                    tests.expect(output.canonicalVolume?.patch ==? .v(0, 2, 0))
                    tests.expect(output.principalVolume.patch ==? .v(0, 2, 0))
                    tests.expect(value: output.principalVertex?.landing)
                }
            }
        }
        /// We should be able to resolve version 0.1.0 with a symbolic volume query.
        if  let tests:TestGroup = tests / "OlderRelease"
        {
            let query:Unidoc.VertexQuery<Unidoc.LookupAdjacent> = .init(
                "\(package):0.1.0", [])
            await tests.do
            {
                if  let output:Unidoc.VertexOutput = tests.expect(
                        value: try await db.query(with: query))
                {
                    tests.expect(output.canonicalVolume?.patch ==? .v(0, 2, 0))
                    tests.expect(output.principalVolume.patch ==? .v(0, 1, 0))
                    tests.expect(value: output.principalVertex?.landing)
                }
            }
        }
        /// We should be able to resolve version 1.0.0 with a symbolic volume query.
        if  let tests:TestGroup = tests / "Prerelease"
        {
            let query:Unidoc.VertexQuery<Unidoc.LookupAdjacent> = .init(
                "\(package):1.0.0", [])
            await tests.do
            {
                if  let output:Unidoc.VertexOutput = tests.expect(
                        value: try await db.query(with: query))
                {
                    tests.expect(output.canonicalVolume?.patch ==? .v(0, 2, 0))
                    tests.expect(nil: output.principalVolume.patch)
                    tests.expect(output.principalVolume.refname ==? "1.0.0-beta.1")
                    tests.expect(value: output.principalVertex?.landing)
                }
            }
        }
    }
}
