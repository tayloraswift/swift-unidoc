import MongoDB
import MongoTesting
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
        let archive:(Documentation, Documentation, Documentation)

        archive.0 = try await toolchain.generateDocs(for: try await .remote(
            package: "swift-nio",
            from: repository,
            at: "2.53.0",
            in: workspace))

        archive.1 = try await toolchain.generateDocs(for: try await .remote(
            package: "swift-nio",
            from: repository,
            at: "2.54.0",
            in: workspace))

        archive.2 = try await toolchain.generateDocs(for: try await .remote(
            package: "swift-nio",
            from: repository,
            at: "main",
            in: workspace))

        let session:Mongo.Session = try await .init(from: pool)

        tests.expect(try await database.store(docs: archive.0, with: session) ==? .init(
            overwritten: false,
            package: 0,
            version: 0,
            id: "swift-nio v2.53.0 x86_64-unknown-linux-gnu"))

        tests.expect(try await database.store(docs: archive.1, with: session) ==? .init(
            overwritten: false,
            package: 0,
            version: 1,
            id: "swift-nio v2.54.0 x86_64-unknown-linux-gnu"))

        tests.expect(try await database.store(docs: archive.2, with: session) ==? .init(
            overwritten: false,
            package: 0,
            version: 2,
            id: "swift-nio @main x86_64-unknown-linux-gnu"))

        tests.expect(try await database.store(docs: archive.2, with: session) ==? .init(
            overwritten: true,
            package: 0,
            version: 3,
            id: "swift-nio @main x86_64-unknown-linux-gnu"))

        archive.0.roundtrip(for: tests, in: workspace.path)
        archive.1.roundtrip(for: tests, in: workspace.path)
        archive.2.roundtrip(for: tests, in: workspace.path)
    }
}
