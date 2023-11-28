import JSON
import MD5
import MongoDB
import MongoTesting
import SymbolGraphBuilder
import SymbolGraphs
import UnidocDB
import UnidocQueries

struct PackageQueries:UnidocDatabaseTestBattery
{
    func run(_ tests:TestGroup,
        accounts:AccountDatabase,
        unidoc:UnidocDatabase,
        pool:Mongo.SessionPool) async throws
    {
        let toolchain:Toolchain = try await .detect()
        let session:Mongo.Session = try await .init(from: pool)

        let empty:SymbolGraph = .init(modules: [])
        var docs:SymbolGraphArchive

        do
        {
            docs = .init(
                metadata: .init(
                    package: .swift,
                    commit: .init(nil, refname: "swift-5.8.1-RELEASE"),
                    triple: toolchain.triple,
                    swift: .stable(.release(.v(5, 8, 1))),
                    products: []),
                graph: empty)

            let _:UnidocDatabase.Uploaded = try await unidoc.store(docs: docs, with: session)
        }
        do
        {
            docs.metadata.package = "swift-debut"
            docs.metadata.commit = nil

            let _:UnidocDatabase.Uploaded = try await unidoc.store(docs: docs, with: session)
        }
        do
        {
            docs.metadata.package = "swift-fearless"
            docs.metadata.commit = .init(0xffffffffffffffffffffffffffffffffffffffff,
                refname: "0.1.2")

            let _:UnidocDatabase.Uploaded = try await unidoc.store(docs: docs, with: session)
        }
        do
        {
            docs.metadata.commit = .init(0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee,
                refname: "0.1.3")

            let _:UnidocDatabase.Uploaded = try await unidoc.store(docs: docs, with: session)
        }
        do
        {
            docs.metadata.package = "swift-speak-now"
            docs.metadata.commit = nil

            let _:UnidocDatabase.Uploaded = try await unidoc.store(docs: docs, with: session)
        }
        do
        {
            docs.metadata.commit = .init(0xffffffffffffffffffffffffffffffffffffffff,
                refname: "0.3.0")

            let _:UnidocDatabase.Uploaded = try await unidoc.store(docs: docs, with: session)
        }
        do
        {
            docs.metadata.package = "swift-red"
            docs.metadata.commit = .init(0xffffffffffffffffffffffffffffffffffffffff,
                refname: "0.4.0")

            let uploaded:UnidocDatabase.Uploaded = try await unidoc.store(docs: docs,
                with: session)

            print(uploaded)
        }

        if  let tests:TestGroup = tests / "AllPackages"
        {
            let query:SearchIndexQuery<Int32> = .init(
                from: UnidocDatabase.Metadata.name,
                tag: nil,
                id: 0)

            await tests.do
            {
                if  let index:SearchIndexQuery<Int32>.Output = tests.expect(
                        value: try await unidoc.execute(query: query, with: session)),
                    let _:MD5 = tests.expect(value: index.hash)
                {
                    switch index.json
                    {
                    case .length:
                        tests.expect(value: nil as [UInt8]?)

                    case .binary(let utf8):
                        let json:JSON = .init(utf8: utf8)
                        tests.expect(try json.decode([String].self) **?
                        [
                            "swift",
                            "swift-debut",
                            "swift-fearless",
                            "swift-red",
                            "swift-speak-now",
                        ])
                    }
                }
            }
        }
    }
}
