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

        var docs:SymbolGraphArchive

        do
        {
            let tests:TestGroup = tests ! "InsertMaster"
            docs = .init(
                metadata: .swift("master", triple: triple, products: []),
                graph: empty)

            tests.expect(try await database.store(docs: docs, with: session) ==? .init(
                id: .init(package: .swift, version: "master", triple: triple),
                edition: .init(package: 0, version: 0),
                type: .insert))
        }
        do
        {
            let tests:TestGroup = tests ! "InsertVersioned"
            docs.metadata.swift = .stable(.release(.v(1, 2, 3)))

            tests.expect(try await database.store(docs: docs, with: session) ==? .init(
                id: .init(package: .swift, version: "1.2.3", triple: triple),
                edition: .init(package: 0, version: 1),
                type: .insert))
        }
        do
        {
            let tests:TestGroup = tests ! "InsertMain"
            docs.metadata.swift = "main"

            tests.expect(try await database.store(docs: docs, with: session) ==? .init(
                id: .init(package: .swift, version: "main", triple: triple),
                edition: .init(package: 0, version: 2),
                type: .insert))
        }
        do
        {
            let tests:TestGroup = tests ! "InsertVersionless"
            docs.metadata.swift = nil

            tests.expect(try await database.store(docs: docs, with: session) ==? .init(
                id: .init(package: .swift, version: "0.0.0", triple: triple),
                edition: .init(package: 0, version: 3),
                type: .insert))
        }
        do
        {
            let tests:TestGroup = tests ! "UpdateMaster"
            docs.metadata.swift = "master"

            tests.expect(try await database.store(docs: docs, with: session) ==? .init(
                id: .init(package: .swift, version: "master", triple: triple),
                edition: .init(package: 0, version: 0),
                type: .update))
        }
        do
        {
            let tests:TestGroup = tests ! "UpdateVersioned"
            docs.metadata.swift = .stable(.release(.v(1, 2, 3)))

            tests.expect(try await database.store(docs: docs, with: session) ==? .init(
                id: .init(package: .swift, version: "1.2.3", triple: triple),
                edition: .init(package: 0, version: 1),
                type: .update))
        }
    }
}
