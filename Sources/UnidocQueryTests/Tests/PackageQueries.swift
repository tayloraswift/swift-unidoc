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
    typealias Configuration = Main.Configuration

    static
    func run(tests:TestGroup,
        pool:Mongo.SessionPool,
        unidoc:Unidoc.DB) async throws
    {
        let toolchain:Toolchain = try await .detect()
        let session:Mongo.Session = try await .init(from: pool)

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
            docs = .init(
                metadata: .init(
                    package: .init(name: .swift),
                    commit: .init(name: "swift-5.8.1-RELEASE"),
                    triple: toolchain.triple,
                    swift: .init(version: .v(5, 8, 1)),
                    products: []),
                graph: empty)

            status.swift = try await unidoc.store(docs: docs, with: session)
        }
        do
        {
            docs.metadata.package.name = "swift-debut"
            docs.metadata.commit = nil

            status.debut = try await unidoc.store(docs: docs, with: session)
        }
        do
        {
            docs.metadata.package.name = "swift-fearless"
            docs.metadata.commit = .init(name: "0.1.2",
                sha1: 0xffffffffffffffffffffffffffffffffffffffff)

            status.fearless.0 = try await unidoc.store(docs: docs, with: session)
        }
        do
        {
            docs.metadata.commit = .init(name: "0.1.3",
                sha1: 0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee)

            status.fearless.1 = try await unidoc.store(docs: docs, with: session)
        }
        do
        {
            docs.metadata.package.name = "swift-speak-now"
            docs.metadata.commit = nil

            status.speakNow.0 = try await unidoc.store(docs: docs, with: session)
        }
        do
        {
            docs.metadata.commit = .init(name: "0.3.0",
                sha1: 0xffffffffffffffffffffffffffffffffffffffff)

            status.speakNow.1 = try await unidoc.store(docs: docs, with: session)
        }
        do
        {
            docs.metadata.package.name = "swift-red"
            docs.metadata.commit = .init(name: "0.4.0",
                sha1: 0xffffffffffffffffffffffffffffffffffffffff)

            status.red = try await unidoc.store(docs: docs, with: session)
        }

        if  let tests:TestGroup = tests / "AllPackages"
        {
            let query:Unidoc.TextResourceQuery<Unidoc.DB.Metadata> = .init(
                tag: nil,
                id: .packages_json)

            await tests.do
            {
                if  let index:Unidoc.TextResourceOutput = tests.expect(
                        value: try await session.query(database: unidoc.id, with: query)),
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
                    filter: .tags(limit: 2))

                await tests.do
                {
                    guard
                    let output:Unidoc.VersionsQuery.Output = tests.expect(
                        value: try await session.query(database: unidoc.id, with: query))
                    else
                    {
                        return
                    }

                    tests.expect(value: output.tagless?.graph)
                    tests.expect(output.prereleases ..? [])
                    tests.expect(output.releases ..? [])
                    tests.expect(output.package.id ==? status.debut.package)
                }
            }
            if  let tests:TestGroup = tests / "Fearless"
            {
                let query:Unidoc.VersionsQuery = .init(
                    symbol: "swift-fearless",
                    filter: .tags(limit: 2))
                await tests.do
                {
                    guard
                    let output:Unidoc.VersionsQuery.Output = tests.expect(
                        value: try await session.query(database: unidoc.id, with: query))
                    else
                    {
                        return
                    }

                    tests.expect(nil: output.tagless?.graph)
                    tests.expect(output.prereleases ..? [])

                    guard tests.expect(output.releases.count ==? 2)
                    else
                    {
                        return
                    }

                    //  Reverse chronological order!
                    tests.expect(output.releases[0].edition.id ==? status.fearless.1.edition)
                    tests.expect(output.releases[1].edition.id ==? status.fearless.0.edition)
                }
            }
            if  let tests:TestGroup = tests / "SpeakNow"
            {
                let query:Unidoc.VersionsQuery = .init(
                    symbol: "swift-speak-now",
                    filter: .tags(limit: 2))
                await tests.do
                {
                    guard
                    let output:Unidoc.VersionsQuery.Output = tests.expect(
                        value: try await session.query(database: unidoc.id, with: query))
                    else
                    {
                        return
                    }

                    tests.expect(value: output.tagless?.graph)
                    tests.expect(output.prereleases ..? [])

                    guard tests.expect(output.releases.count ==? 1)
                    else
                    {
                        return
                    }

                    tests.expect(output.releases[0].edition.id ==? status.speakNow.1.edition)
                }
            }
            if  let tests:TestGroup = tests / "Red"
            {
                let query:Unidoc.VersionsQuery = .init(
                    symbol: "swift-red",
                    filter: .tags(limit: 2))
                await tests.do
                {
                    guard
                    let output:Unidoc.VersionsQuery.Output = tests.expect(
                        value: try await session.query(database: unidoc.id, with: query))
                    else
                    {
                        return
                    }

                    tests.expect(nil: output.tagless?.graph)
                    tests.expect(output.prereleases ..? [])

                    guard tests.expect(output.releases.count ==? 1)
                    else
                    {
                        return
                    }

                    tests.expect(output.releases[0].edition.id ==? status.red.edition)
                }
            }
        }
    }
}
