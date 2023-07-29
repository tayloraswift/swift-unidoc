import MongoDB
import MongoTesting
import SemanticVersions
import SymbolGraphBuilder
import SymbolGraphs
import SymbolGraphTesting
import UnidocDatabase

struct Objects:MongoTestBattery
{
    func run(_ tests:TestGroup, pool:Mongo.SessionPool, database:Mongo.Database) async throws
    {
        let database:Database = try await .setup(database, in: pool)

        let workspace:Workspace = try await .create(at: ".testing")
        let toolchain:Toolchain = try await .detect()

        let repository:String = "https://github.com/apple/swift-nio"
        var archives:[Documentation] = []
        for ref:String in ["2.53.0", "2.54.0", "2.55.0", "2.56.0", "2.57.0", "main"]
        {
            if  let archive:Documentation = try? .load(package: "swift-nio",
                    at: .init(ref),
                    in: workspace.path)
            {
                archives.append(archive)
            }
            else
            {
                archives.append(try await toolchain.generateDocs(for: try await .remote(
                    package: "swift-nio",
                    from: repository,
                    at: ref,
                    in: workspace)))
            }
        }

        let session:Mongo.Session = try await .init(from: pool)

        tests.expect(try await database.store(docs: archives[0], with: session) ==? .init(
            overwritten: false,
            package: 0,
            version: 0,
            id: "swift-nio v2.53.0 x86_64-unknown-linux-gnu"))

        tests.expect(try await database.store(docs: archives[1], with: session) ==? .init(
            overwritten: false,
            package: 0,
            version: 1,
            id: "swift-nio v2.54.0 x86_64-unknown-linux-gnu"))

        tests.expect(try await database.store(docs: archives[1], with: session) ==? .init(
            overwritten: true,
            package: 0,
            version: 1,
            id: "swift-nio v2.54.0 x86_64-unknown-linux-gnu"))

        tests.expect(try await database.store(docs: archives.last!, with: session) ==? .init(
            overwritten: false,
            package: 0,
            version: 2,
            id: "swift-nio @main x86_64-unknown-linux-gnu"))

        tests.expect(try await database.store(docs: archives.last!, with: session) ==? .init(
            overwritten: true,
            package: 0,
            version: 2,
            id: "swift-nio @main x86_64-unknown-linux-gnu"))

        tests.expect(try await database.store(docs: archives[0], with: session) ==? .init(
            overwritten: true,
            package: 0,
            version: 0,
            id: "swift-nio v2.53.0 x86_64-unknown-linux-gnu"))

        for archive:Documentation in archives
        {
            archive.roundtrip(for: tests, in: workspace.path)
        }
    }
}
