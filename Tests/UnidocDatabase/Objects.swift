import MongoDB
import MongoTesting
import SymbolGraphs
import UnidocDriver
import UnidocDatabase

struct Objects:MongoTestBattery
{
    func run(_ tests:TestGroup, pool:Mongo.SessionPool, database:Mongo.Database) async throws
    {
        let database:DocumentationDatabase = try await .setup(mongodb: pool, name: database)

        let workspace:Workspace = try await .create(at: ".unidoc-testing")
        let toolchain:Toolchain = try await .detect()

        let repository:String = "https://github.com/apple/swift-nio"
        let archive:(DocumentationArchive, DocumentationArchive, DocumentationArchive)

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

        tests.expect(try await database.push(archive: archive.0, with: session) ==? .init(
            overwritten: false,
            package: 0,
            version: 0))

        tests.expect(try await database.push(archive: archive.1, with: session) ==? .init(
            overwritten: false,
            package: 0,
            version: 1))

        tests.expect(try await database.push(archive: archive.2, with: session) ==? .init(
            overwritten: false,
            package: 0,
            version: 2))

        tests.expect(try await database.push(archive: archive.2, with: session) ==? .init(
            overwritten: true,
            package: 0,
            version: 3))
    }
}
