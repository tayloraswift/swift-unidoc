import MongoDB
import ModuleGraphs
import MongoTesting
import SemanticVersions
import SymbolGraphs
import UnidocDatabase

struct PackageVersions:MongoTestBattery
{
    func run(_ tests:TestGroup, pool:Mongo.SessionPool, database:Mongo.Database) async throws
    {
        let database:PackageDatabase = await .setup(as: database, in: pool)

        let session:Mongo.Session = try await .init(from: pool)

        let triple:Triple = .init("x86_64-unknown-linux-gnu")!
        let empty:SymbolGraph = .init(modules: [])

        var docs:Documentation


        docs = .init(
            metadata: .swift(triple: triple, version: "master", products: []),
            graph: empty)

        tests.expect(try await database.store(docs: docs, with: session) ==? .init(
            id: "swift @master \(triple)",
            zone: .init(package: 0, version: 0),
            overwritten: false))


        docs.metadata.version = .stable(.release(.v(1, 2, 3)))

        tests.expect(try await database.store(docs: docs, with: session) ==? .init(
            id: "swift v1.2.3 \(triple)",
            zone: .init(package: 0, version: 1),
            overwritten: false))


        docs.metadata.version = "main"

        tests.expect(try await database.store(docs: docs, with: session) ==? .init(
            id: "swift @main \(triple)",
            zone: .init(package: 0, version: 2),
            overwritten: false))


        docs.metadata.version = "master"

        tests.expect(try await database.store(docs: docs, with: session) ==? .init(
            id: "swift @master \(triple)",
            zone: .init(package: 0, version: 0),
            overwritten: true))


        docs.metadata.version = .stable(.release(.v(1, 2, 3)))

        tests.expect(try await database.store(docs: docs, with: session) ==? .init(
            id: "swift v1.2.3 \(triple)",
            zone: .init(package: 0, version: 1),
            overwritten: true))
    }
}
