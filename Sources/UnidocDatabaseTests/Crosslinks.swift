import MongoDB
import MongoTesting
import SymbolGraphs
import UnidocDriver
import UnidocDatabase

struct Crosslinks:MongoTestBattery
{
    func run(_ tests:TestGroup, pool:Mongo.SessionPool, database:Mongo.Database) async throws
    {
        let database:DocumentationDatabase = try await .setup(mongodb: pool, name: database)

        let workspace:Workspace = try await .create(at: ".unidoc-testing")
        let toolchain:Toolchain = try await .detect()

        let example:Documentation = try await toolchain.generateDocs(
            for: try await .local(package: "swift-crosslinks",
                from: "TestPackages",
                in: workspace,
                clean: true),
            pretty: true)

        let swift:Documentation = try await toolchain.generateDocs(
            for: try await .swift(in: workspace, clean: true))

        let session:Mongo.Session = try await .init(from: pool)

        tests.expect(try await database.publish(docs: swift, with: session) ==? .init(
            overwritten: false,
            package: 0,
            version: 0,
            id: "swift v5.8.0 x86_64-unknown-linux-gnu"))

        tests.expect(try await database.publish(docs: example, with: session) ==? .init(
            overwritten: false,
            package: 1,
            version: 0,
            id: "$anonymous"))
    }
}
