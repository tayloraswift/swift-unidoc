import JSON
import MD5
import MongoDB
import MongoTesting
import SymbolGraphBuilder
import SymbolGraphs
@_spi(testable)
import UnidocDB
import UnidocQueries

struct PackageQueries:UnidocDatabaseTestBattery
{
    typealias Configuration = Main.Configuration

    static
    func run(tests:TestGroup, db:Unidoc.DB) async throws
    {
        let empty:SymbolGraph = .init(modules: [])
        var docs:SymbolGraphObject<Void>

        let status:
        (
            swift:Unidoc.UploadStatus,
            debut:Unidoc.UploadStatus,
            fearless:(Unidoc.UploadStatus, Unidoc.UploadStatus),
            speakNow:(Unidoc.UploadStatus, Unidoc.UploadStatus),
            red:Unidoc.UploadStatus
        )

        do
        {
            let toolchain:SSGC.Toolchain = try .detect()
            docs = .init(
                metadata: .init(
                    package: .init(name: .swift),
                    commit: .init(name: "swift-5.8.1-RELEASE"),
                    triple: toolchain.splash.triple,
                    swift: .init(version: .v(5, 8, 1)),
                    products: []),
                graph: empty)

            status.swift = try await db.store(docs: docs)
        }
        do
        {
            docs.metadata.package.name = "swift-debut"
            docs.metadata.commit = nil

            status.debut = try await db.store(docs: docs)
        }
        do
        {
            docs.metadata.package.name = "swift-fearless"
            docs.metadata.commit = .init(name: "0.1.2",
                sha1: 0xffffffffffffffffffffffffffffffffffffffff)

            status.fearless.0 = try await db.store(docs: docs)
        }
        do
        {
            docs.metadata.commit = .init(name: "0.1.3",
                sha1: 0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee)

            status.fearless.1 = try await db.store(docs: docs)
        }
        do
        {
            docs.metadata.package.name = "swift-speak-now"
            docs.metadata.commit = nil

            status.speakNow.0 = try await db.store(docs: docs)
        }
        do
        {
            docs.metadata.commit = .init(name: "0.3.0",
                sha1: 0xffffffffffffffffffffffffffffffffffffffff)

            status.speakNow.1 = try await db.store(docs: docs)
        }
        do
        {
            docs.metadata.package.name = "swift-red"
            docs.metadata.commit = .init(name: "0.4.0",
                sha1: 0xffffffffffffffffffffffffffffffffffffffff)

            status.red = try await db.store(docs: docs)
        }

        if  let tests:TestGroup = tests / "AllPackages"
        {
            let query:Unidoc.TextResourceQuery<Unidoc.DB.Metadata> = .init(
                tag: nil,
                id: .packages_json)

            await tests.do
            {
                if  let index:Unidoc.TextResourceOutput = tests.expect(
                        value: try await db.query(with: query)),
                    let _:MD5 = tests.expect(value: index.hash)
                {
                    switch index.text
                    {
                    case .inline(.utf8(let utf8)):
                        let json:JSON = .init(utf8: utf8)
                        tests.expect(try json.decode([String].self) **?
                        [
                            "swift",
                            "swift-debut",
                            "swift-fearless",
                            "swift-red",
                            "swift-speak-now",
                        ])

                    default:
                        tests.expect(value: nil as [UInt8]?)
                    }
                }
            }
        }

        if  let tests:TestGroup = tests / "Tags"
        {
            if  let tests:TestGroup = tests / "Debut"
            {
                let query:Unidoc.VersionsQuery = .init(
                    symbol: "swift-debut",
                    limitTags: 2)

                await tests.do
                {
                    guard
                    let output:Unidoc.VersionsQuery.Output = tests.expect(
                        value: try await db.query(with: query))
                    else
                    {
                        return
                    }

                    tests.expect(output.versions.count ==? 1)
                    tests.expect(output.versions[0].edition.id ==? status.debut.edition)
                    tests.expect(output.package.id ==? status.debut.package)
                }
            }
            if  let tests:TestGroup = tests / "Fearless"
            {
                let query:Unidoc.VersionsQuery = .init(
                    symbol: "swift-fearless",
                    limitTags: 2)
                await tests.do
                {
                    guard
                    let output:Unidoc.VersionsQuery.Output = tests.expect(
                        value: try await db.query(with: query))
                    else
                    {
                        return
                    }

                    guard tests.expect(output.versions.count ==? 2)
                    else
                    {
                        return
                    }

                    //  Reverse chronological order!
                    tests.expect(output.versions[0].edition.id ==?
                        status.fearless.1.edition)
                    tests.expect(output.versions[1].edition.id ==?
                        status.fearless.0.edition)
                }
            }
            if  let tests:TestGroup = tests / "SpeakNow"
            {
                let query:Unidoc.VersionsQuery = .init(
                    symbol: "swift-speak-now",
                    limitTags: 2)
                await tests.do
                {
                    guard
                    let output:Unidoc.VersionsQuery.Output = tests.expect(
                        value: try await db.query(with: query))
                    else
                    {
                        return
                    }

                    guard tests.expect(output.versions.count ==? 2)
                    else
                    {
                        return
                    }

                    tests.expect(output.versions[0].edition.id ==?
                        status.speakNow.0.edition)
                    tests.expect(output.versions[1].edition.id ==?
                        status.speakNow.1.edition)
                }
            }
            if  let tests:TestGroup = tests / "Red"
            {
                let query:Unidoc.VersionsQuery = .init(
                    symbol: "swift-red",
                    limitTags: 2)
                await tests.do
                {
                    guard
                    let output:Unidoc.VersionsQuery.Output = tests.expect(
                        value: try await db.query(with: query))
                    else
                    {
                        return
                    }

                    guard tests.expect(output.versions.count ==? 1)
                    else
                    {
                        return
                    }

                    tests.expect(output.versions[0].edition.id ==? status.red.edition)
                }
            }
        }
    }
}
