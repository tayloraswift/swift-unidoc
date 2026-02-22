import JSON
import MongoDB
import SHA1
import SymbolGraphs
import Testing
@_spi(testable) import UnidocDB
import UnidocQueries
import UnidocTesting

@Suite struct PackageQueries: Unidoc.TestBattery {
    @Test func packageQueries() async throws {
        try await self.run(in: "PackageQueries")
    }

    func run(with db: Unidoc.DB) async throws {
        let empty: SymbolGraph = .init(modules: [])
        var docs: SymbolGraphObject<Void>

        let status: (
            swift: Unidoc.UploadStatus,
            debut: Unidoc.UploadStatus,
            fearless: (Unidoc.UploadStatus, Unidoc.UploadStatus),
            speakNow: (Unidoc.UploadStatus, Unidoc.UploadStatus),
            red: Unidoc.UploadStatus
        )

        do {
            docs = .init(
                metadata: .init(
                    package: .init(name: .swift),
                    commit: .init(name: "swift-5.8.1-RELEASE"),
                    triple: .aarch64_unknown_linux_gnu,
                    swift: .init(version: .v(5, 8, 1)),
                    products: []
                ),
                graph: empty
            )

            status.swift = try await db.store(docs: docs)
        }
        do {
            docs.metadata.package.name = "swift-debut"
            docs.metadata.commit = nil

            status.debut = try await db.store(docs: docs)
        }
        do {
            docs.metadata.package.name = "swift-fearless"
            docs.metadata.commit = .init(
                name: "0.1.2",
                sha1: 0xffffffffffffffffffffffffffffffffffffffff
            )

            status.fearless.0 = try await db.store(docs: docs)
        }
        do {
            docs.metadata.commit = .init(
                name: "0.1.3",
                sha1: 0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
            )

            status.fearless.1 = try await db.store(docs: docs)
        }
        do {
            docs.metadata.package.name = "swift-speak-now"
            docs.metadata.commit = nil

            status.speakNow.0 = try await db.store(docs: docs)
        }
        do {
            docs.metadata.commit = .init(
                name: "0.3.0",
                sha1: 0xffffffffffffffffffffffffffffffffffffffff
            )

            status.speakNow.1 = try await db.store(docs: docs)
        }
        do {
            docs.metadata.package.name = "swift-red"
            docs.metadata.commit = .init(
                name: "0.4.0",
                sha1: 0xffffffffffffffffffffffffffffffffffffffff
            )

            status.red = try await db.store(docs: docs)
        }

        do {
            let query: Unidoc.TextResourceQuery<Unidoc.DB.Metadata> = .init(
                tag: nil,
                id: .packages_json
            )

            let index: Unidoc.TextResourceOutput = try #require(try await db.query(with: query))

            switch index.text {
            case .inline(.utf8(let utf8)):
                let json: JSON = .init(utf8: utf8)
                #expect(
                    try json.decode(Set<String>.self) == [
                        "swift",
                        "swift-debut",
                        "swift-fearless",
                        "swift-red",
                        "swift-speak-now",
                    ]
                )

            default:
                Issue.record()
            }
        }

        do {
            let query: Unidoc.VersionsQuery = .init(
                symbol: "swift-debut",
                limitTags: 2
            )

            let output: Unidoc.VersionsQuery.Output = try #require(
                try await db.query(
                    with: query
                )
            )

            #expect(output.versions.count == 1)
            #expect(output.versions[0].edition.id == status.debut.edition)
            #expect(output.package.id == status.debut.package)
        }
        do {
            let query: Unidoc.VersionsQuery = .init(
                symbol: "swift-fearless",
                limitTags: 2
            )

            let output: Unidoc.VersionsQuery.Output = try #require(
                try await db.query(
                    with: query
                )
            )

            #expect(output.versions.count == 2)

            //  Reverse chronological order!
            #expect(
                output.versions[0].edition.id ==
                status.fearless.1.edition
            )
            #expect(
                output.versions[1].edition.id ==
                status.fearless.0.edition
            )
        }
        do {
            let query: Unidoc.VersionsQuery = .init(
                symbol: "swift-speak-now",
                limitTags: 2
            )

            let output: Unidoc.VersionsQuery.Output = try #require(
                try await db.query(
                    with: query
                )
            )

            #expect(output.versions.count == 2)

            #expect(output.versions[0].edition.id == status.speakNow.0.edition)
            #expect(output.versions[1].edition.id == status.speakNow.1.edition)
        }
        do {
            let query: Unidoc.VersionsQuery = .init(
                symbol: "swift-red",
                limitTags: 2
            )

            let output: Unidoc.VersionsQuery.Output = try #require(
                try await db.query(
                    with: query
                )
            )

            #expect(output.versions.count == 1)
            #expect(output.versions[0].edition.id == status.red.edition)
        }
    }
}
