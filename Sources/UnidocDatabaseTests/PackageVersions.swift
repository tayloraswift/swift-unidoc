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
            let tests:TestGroup = tests ! "InsertVersionedSwift"

            docs = .init(
                metadata: .init(
                    package: .swift,
                    commit: .init(nil, refname: "swift-5.8.1-RELEASE"),
                    triple: triple,
                    swift: .stable(.release(.v(5, 8, 1))),
                    products: []),
                graph: empty)

            tests.expect(try await database.store(docs: docs, with: session) ==? .init(
                id: .init(package: .swift, version: "5.8.1", triple: triple),
                edition: .init(package: 0, version: 0),
                type: .insert))
        }
        do
        {
            let tests:TestGroup = tests ! "InsertLocal"

            docs.metadata.package = "swift-not-named-swift"
            docs.metadata.commit = nil

            tests.expect(try await database.store(docs: docs, with: session) ==? .init(
                id: .init(package: "swift-not-named-swift", version: "0.0.0", triple: triple),
                edition: .init(package: 1, version: -1),
                type: .insert))
        }
        do
        {
            let tests:TestGroup = tests ! "InsertVersioned"

            docs.metadata.commit = .init(0xffffffffffffffffffffffffffffffffffffffff,
                refname: "1.2.3")

            tests.expect(try await database.store(docs: docs, with: session) ==? .init(
                id: .init(package: "swift-not-named-swift", version: "1.2.3", triple: triple),
                edition: .init(package: 1, version: 0),
                type: .insert))
        }
        do
        {
            let tests:TestGroup = tests ! "InsertMaster"

            docs.metadata.commit = .init(0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee,
                refname: "master")

            tests.expect(try await database.store(docs: docs, with: session) ==? .init(
                id: .init(package: "swift-not-named-swift", version: "master", triple: triple),
                edition: .init(package: 1, version: 1),
                type: .insert))
        }
        do
        {
            let tests:TestGroup = tests ! "UpdateLocal"

            docs.metadata.commit = nil

            tests.expect(try await database.store(docs: docs, with: session) ==? .init(
                id: .init(package: "swift-not-named-swift", version: "0.0.0", triple: triple),
                edition: .init(package: 1, version: -1),
                type: .update))
        }
        do
        {
            let tests:TestGroup = tests ! "UpdateMaster"

            docs.metadata.commit = .init(0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee,
                refname: "master")

            tests.expect(try await database.store(docs: docs, with: session) ==? .init(
                id: .init(package: "swift-not-named-swift", version: "master", triple: triple),
                edition: .init(package: 1, version: 1),
                type: .update))
        }
        do
        {
            let tests:TestGroup = tests ! "UpdateVersioned"

            docs.metadata.commit = .init(0xffffffffffffffffffffffffffffffffffffffff,
                refname: "1.2.3")

            tests.expect(try await database.store(docs: docs, with: session) ==? .init(
                id: .init(package: "swift-not-named-swift", version: "1.2.3", triple: triple),
                edition: .init(package: 1, version: 0),
                type: .update))
        }
    }
}
