import MongoDB
import SemanticVersions
import SymbolGraphs
import Symbols
import Testing
import UnidocDB
import UnidocTesting

@Suite
struct SymbolGraphs:Unidoc.TestBattery
{
    @Test
    func symbolGraphs() async throws
    {
        try await self.run(in: "SymbolGraphs")
    }

    func run(with unidoc:Unidoc.DB) async throws
    {
        let triple:Symbol.Triple = .x86_64_unknown_linux_gnu
        let empty:SymbolGraph = .init(modules: [])

        var docs:SymbolGraphObject<Void>

        do
        {
            docs = .init(
                metadata: .init(
                    package: .init(scope: "apple", name: .swift),
                    commit: .init(name: "swift-5.8.1-RELEASE"),
                    triple: triple,
                    swift: .init(version: .v(5, 8, 1)),
                    products: []),
                graph: empty)

            #expect(try await unidoc.store(docs: docs) == .init(
                    edition: .init(package: 0, version: 0),
                    updated: false),
                "InsertVersionedSwift")
        }
        do
        {
            docs.metadata.package.scope = "orange"
            docs.metadata.package.name = "swift-not-named-swift"
            docs.metadata.commit = nil

            #expect(try await unidoc.store(docs: docs) == .init(
                    edition: .init(package: 1, version: -1),
                    updated: false),
                "InsertLocalSwift")
        }
        do
        {
            docs.metadata.commit = .init(name: "1.2.3",
                sha1: 0xffffffffffffffffffffffffffffffffffffffff)

            #expect(try await unidoc.store(docs: docs) == .init(
                    edition: .init(package: 1, version: 0),
                    updated: false),
                "InsertRelease")
        }
        do
        {

            docs.metadata.commit = .init(name: "2.0.0-beta1",
                sha1: 0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee)

            #expect(try await unidoc.store(docs: docs) == .init(
                    edition: .init(package: 1, version: 1),
                    updated: false),
                "InsertPrerelease")
        }
        do
        {
            docs.metadata.commit = nil

            #expect(try await unidoc.store(docs: docs) == .init(
                    edition: .init(package: 1, version: -1),
                    updated: true),
                "UpdateLocal")
        }
        do
        {
            docs.metadata.commit = .init(name: "2.0.0-beta1",
                sha1: 0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee)

            #expect(try await unidoc.store(docs: docs) == .init(
                    edition: .init(package: 1, version: 1),
                    updated: true),
                "UpdatePrerelease")
        }
        do
        {
            docs.metadata.commit = .init(name: "1.2.3",
                sha1: 0xffffffffffffffffffffffffffffffffffffffff)

            #expect(try await unidoc.store(docs: docs) == .init(
                    edition: .init(package: 1, version: 0),
                    updated: true),
                "UpdateRelease")
        }
        do
        {
            try await unidoc.alias(
                existing: docs.metadata.package.id,
                package: docs.metadata.package.name)

            docs.metadata.package.scope = nil

            #expect(try await unidoc.store(docs: docs) == .init(
                    edition: .init(package: 1, version: 0),
                    updated: true),
                "UpdateReleaseUnscoped")
        }
        do
        {
            docs.metadata.package.scope = "banana"

            #expect(try await unidoc.store(docs: docs) == .init(
                    edition: .init(package: 2, version: 0),
                    updated: false),
                "InsertReleaseWithDifferentScope")
        }
    }
}
