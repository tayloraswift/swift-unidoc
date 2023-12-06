import MongoDB
import MongoTesting
import Symbols
import SymbolGraphBuilder
import SymbolGraphs
import SymbolGraphTesting
import Unidoc
import UnidocDB
import UnidocQueries
import UnidocRecords

struct VolumeQueries:UnidocDatabaseTestBattery
{
    func run(_ tests:TestGroup,
        accounts:AccountDatabase,
        unidoc:UnidocDatabase,
        pool:Mongo.SessionPool) async throws
    {
        let workspace:Workspace = try await .create(at: ".testing")
        let toolchain:Toolchain = try await .detect()

        let session:Mongo.Session = try await .init(from: pool)
        let package:Symbol.Package = "swift-version-controlled"

        for (i, tag):(Int32, String) in zip(0..., ["0.1.0", "0.2.0", "1.0.0-beta.1"])
        {
            let empty:SymbolGraphArchive = .init(metadata: .init(
                    package: package,
                    commit: .init(nil, refname: tag),
                    triple: toolchain.triple,
                    swift: toolchain.version),
                graph: .init(modules: []))

            empty.roundtrip(for: tests, in: workspace.path)

            let v:Unidoc.Version = .init(rawValue: i)
            tests.expect(try await unidoc.publish(docs: empty, with: session).0 ==? .init(
                edition: .init(package: 0, version: v),
                updated: false))
        }

        /// We should be able to resolve version 0.2.0 with a symbolic patch query.
        if  let tests:TestGroup = tests / "LatestRelease"
        {
            let query:Volume.LookupQuery<Volume.LookupAdjacent, Any> = .init("\(package)", [])
            await tests.do
            {
                if  let output:Volume.LookupOutput<Any> = tests.expect(
                        value: try await unidoc.execute(query: query, with: session)),
                    let output:Volume.PrincipalOutput = tests.expect(value: output.principal)
                {
                    tests.expect(output.volumeOfLatest?.patch ==? .v(0, 2, 0))
                    tests.expect(output.volume.patch ==? .v(0, 2, 0))
                    tests.expect(value: output.vertex?.global)
                }
            }
        }
        /// We should be able to resolve version 0.2.0 with a symbolic volume query.
        if  let tests:TestGroup = tests / "CurrentRelease"
        {
            let query:Volume.LookupQuery<Volume.LookupAdjacent, Any> = .init(
                "\(package):0.2.0", [])
            await tests.do
            {
                if  let output:Volume.LookupOutput<Any> = tests.expect(
                        value: try await unidoc.execute(query: query, with: session)),
                    let output:Volume.PrincipalOutput = tests.expect(value: output.principal)
                {
                    tests.expect(output.volumeOfLatest?.patch ==? .v(0, 2, 0))
                    tests.expect(output.volume.patch ==? .v(0, 2, 0))
                    tests.expect(value: output.vertex?.global)
                }
            }
        }
        /// We should be able to resolve version 0.1.0 with a symbolic volume query.
        if  let tests:TestGroup = tests / "OlderRelease"
        {
            let query:Volume.LookupQuery<Volume.LookupAdjacent, Any> = .init(
                "\(package):0.1.0", [])
            await tests.do
            {
                if  let output:Volume.LookupOutput<Any> = tests.expect(
                        value: try await unidoc.execute(query: query, with: session)),
                    let output:Volume.PrincipalOutput = tests.expect(value: output.principal)
                {
                    tests.expect(output.volumeOfLatest?.patch ==? .v(0, 2, 0))
                    tests.expect(output.volume.patch ==? .v(0, 1, 0))
                    tests.expect(value: output.vertex?.global)
                }
            }
        }
        /// We should be able to resolve version 1.0.0 with a symbolic volume query.
        if  let tests:TestGroup = tests / "Prerelease"
        {
            let query:Volume.LookupQuery<Volume.LookupAdjacent, Any> = .init(
                "\(package):1.0.0", [])
            await tests.do
            {
                if  let output:Volume.LookupOutput<Any> = tests.expect(
                        value: try await unidoc.execute(query: query, with: session)),
                    let output:Volume.PrincipalOutput = tests.expect(value: output.principal)
                {
                    tests.expect(output.volumeOfLatest?.patch ==? .v(0, 2, 0))
                    tests.expect(nil: output.volume.patch)
                    tests.expect(output.volume.refname ==? "1.0.0-beta.1")
                    tests.expect(value: output.vertex?.global)
                }
            }
        }
    }
}
