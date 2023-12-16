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
        unidoc:UnidocDatabase) async throws
    {
        let toolchain:Toolchain = try await .detect()
        let session:Mongo.Session = try await .init(from: pool)

        let empty:SymbolGraph = .init(modules: [])
        var docs:SymbolGraphArchive

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
                    package: .swift,
                    commit: .init(nil, refname: "swift-5.8.1-RELEASE"),
                    triple: toolchain.triple,
                    swift: .stable(.release(.v(5, 8, 1))),
                    products: []),
                graph: empty)

            status.swift = try await unidoc.store(docs: docs, with: session)
        }
        do
        {
            docs.metadata.package = "swift-debut"
            docs.metadata.commit = nil

            status.debut = try await unidoc.store(docs: docs, with: session)
        }
        do
        {
            docs.metadata.package = "swift-fearless"
            docs.metadata.commit = .init(0xffffffffffffffffffffffffffffffffffffffff,
                refname: "0.1.2")

            status.fearless.0 = try await unidoc.store(docs: docs, with: session)
        }
        do
        {
            docs.metadata.commit = .init(0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee,
                refname: "0.1.3")

            status.fearless.1 = try await unidoc.store(docs: docs, with: session)
        }
        do
        {
            docs.metadata.package = "swift-speak-now"
            docs.metadata.commit = nil

            status.speakNow.0 = try await unidoc.store(docs: docs, with: session)
        }
        do
        {
            docs.metadata.commit = .init(0xffffffffffffffffffffffffffffffffffffffff,
                refname: "0.3.0")

            status.speakNow.1 = try await unidoc.store(docs: docs, with: session)
        }
        do
        {
            docs.metadata.package = "swift-red"
            docs.metadata.commit = .init(0xffffffffffffffffffffffffffffffffffffffff,
                refname: "0.4.0")

            status.red = try await unidoc.store(docs: docs, with: session)
        }

        if  let tests:TestGroup = tests / "AllPackages"
        {
            let query:SearchIndexQuery<UnidocDatabase.Metadata> = .init(
                tag: nil,
                id: 0)

            await tests.do
            {
                if  let index:SearchIndexQuery<UnidocDatabase.Metadata>.Output = tests.expect(
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

        if  let tests:TestGroup = tests / "Tags"
        {
            if  let tests:TestGroup = tests / "Debut"
            {
                let query:Unidoc.PackageQuery = .init(package: "swift-debut", limit: 2)
                await tests.do
                {
                    guard
                    let output:Unidoc.PackageQuery.Output = tests.expect(
                        value: try await unidoc.execute(query: query, with: session))
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
                let query:Unidoc.PackageQuery = .init(package: "swift-fearless", limit: 2)
                await tests.do
                {
                    guard
                    let output:Unidoc.PackageQuery.Output = tests.expect(
                        value: try await unidoc.execute(query: query, with: session))
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
                let query:Unidoc.PackageQuery = .init(package: "swift-speak-now", limit: 2)
                await tests.do
                {
                    guard
                    let output:Unidoc.PackageQuery.Output = tests.expect(
                        value: try await unidoc.execute(query: query, with: session))
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
                let query:Unidoc.PackageQuery = .init(package: "swift-red", limit: 2)
                await tests.do
                {
                    guard
                    let output:Unidoc.PackageQuery.Output = tests.expect(
                        value: try await unidoc.execute(query: query, with: session))
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
