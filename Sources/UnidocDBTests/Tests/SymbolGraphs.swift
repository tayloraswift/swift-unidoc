import MongoDB
import MongoTesting
import SemanticVersions
import SymbolGraphs
@_spi(testable)
import UnidocDB

struct SymbolGraphs:MongoTestBattery
{
    typealias Configuration = Main.Configuration

    static
    func run(tests:TestGroup, pool:Mongo.SessionPool, database:Mongo.Database) async throws
    {
        let database:Unidoc.DB = await .setup(as: database, in: pool)

        let session:Mongo.Session = try await .init(from: pool)

        let triple:Triple = .init("x86_64-unknown-linux-gnu")!
        let empty:SymbolGraph = .init(modules: [])

        var docs:SymbolGraphObject<Void>

        do
        {
            let tests:TestGroup = tests ! "InsertVersionedSwift"

            docs = .init(
                metadata: .init(
                    package: .init(scope: "apple", name: .swift),
                    commit: .init(name: "swift-5.8.1-RELEASE"),
                    triple: triple,
                    swift: .stable(.release(.v(5, 8, 1))),
                    products: []),
                graph: empty)

            tests.expect(try await database.store(docs: docs, with: session) ==? .init(
                edition: .init(package: 0, version: 0),
                updated: false))
        }
        do
        {
            let tests:TestGroup = tests ! "InsertLocal"

            docs.metadata.package.scope = "orange"
            docs.metadata.package.name = "swift-not-named-swift"
            docs.metadata.commit = nil

            tests.expect(try await database.store(docs: docs, with: session) ==? .init(
                edition: .init(package: 1, version: -1),
                updated: false))
        }
        do
        {
            let tests:TestGroup = tests ! "InsertRelease"

            docs.metadata.commit = .init(name: "1.2.3",
                sha1: 0xffffffffffffffffffffffffffffffffffffffff)

            tests.expect(try await database.store(docs: docs, with: session) ==? .init(
                edition: .init(package: 1, version: 0),
                updated: false))
        }
        do
        {
            let tests:TestGroup = tests ! "InsertPrerelease"

            docs.metadata.commit = .init(name: "2.0.0-beta1",
                sha1: 0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee)

            tests.expect(try await database.store(docs: docs, with: session) ==? .init(
                edition: .init(package: 1, version: 1),
                updated: false))
        }
        do
        {
            let tests:TestGroup = tests ! "UpdateLocal"

            docs.metadata.commit = nil

            tests.expect(try await database.store(docs: docs, with: session) ==? .init(
                edition: .init(package: 1, version: -1),
                updated: true))
        }
        do
        {
            let tests:TestGroup = tests ! "UpdatePrerelease"

            docs.metadata.commit = .init(name: "2.0.0-beta1",
                sha1: 0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee)

            tests.expect(try await database.store(docs: docs, with: session) ==? .init(
                edition: .init(package: 1, version: 1),
                updated: true))
        }
        do
        {
            let tests:TestGroup = tests ! "UpdateRelease"

            docs.metadata.commit = .init(name: "1.2.3",
                sha1: 0xffffffffffffffffffffffffffffffffffffffff)

            tests.expect(try await database.store(docs: docs, with: session) ==? .init(
                edition: .init(package: 1, version: 0),
                updated: true))
        }
        do
        {
            let tests:TestGroup = tests ! "UpdateReleaseUnscoped"

            tests.expect(value: try? await database.alias(
                existing: docs.metadata.package.id,
                package: docs.metadata.package.name,
                with: session))

            docs.metadata.package.scope = nil

            tests.expect(try await database.store(docs: docs, with: session) ==? .init(
                edition: .init(package: 1, version: 0),
                updated: true))
        }
        do
        {
            let tests:TestGroup = tests ! "InsertReleaseWithDifferentScope"

            docs.metadata.package.scope = "banana"

            tests.expect(try await database.store(docs: docs, with: session) ==? .init(
                edition: .init(package: 2, version: 0),
                updated: false))
        }
    }
}
