import MongoDB
import SymbolGraphs
import SymbolGraphTesting
import Symbols
import System_
import Testing
import Unidoc
@_spi(testable)
import UnidocDB
import UnidocQueries
import UnidocRecords

@Suite
struct VolumeQueries:Unidoc.TestBattery
{
    @Test
    func volumeQueries() async throws
    {
        try await self.run(in: "VolumeQueries")
    }

    func run(with db:Unidoc.DB) async throws
    {
        let directory:FilePath.Directory = "TestPackages"
        let package:Symbol.Package = "swift-version-controlled"

        for (i, tag):(Int32, String) in zip(0..., ["0.1.0", "0.2.0", "1.0.0-beta.1"])
        {
            let empty:SymbolGraphObject<Void> = .init(metadata: .init(
                    package: .init(name: package),
                    commit: .init(name: tag),
                    triple: .aarch64_unknown_linux_gnu,
                    swift: .init(version: .v(9999, 0, 0))),
                graph: .init(modules: []))

            try empty.roundtrip(in: directory)

            let v:Unidoc.Version = .init(rawValue: i)
            #expect(try await db.store(linking: empty).0 == .init(
                edition: .init(package: 0, version: v),
                updated: false))
        }

        do
        {
            /// We should be able to resolve version 0.2.0 with a symbolic patch query.
            let query:Unidoc.VertexQuery<Unidoc.LookupAdjacent> = .init("\(package)", [])
            let output:Unidoc.VertexOutput = try #require(try await db.query(with: query))

            #expect(output.canonicalVolume?.patch == .v(0, 2, 0))
            #expect(output.principalVolume.patch == .v(0, 2, 0))
            #expect(output.principalVertex?.landing != nil)
        }

        do
        {
            /// We should be able to resolve version 0.2.0 with a symbolic volume query.
            let query:Unidoc.VertexQuery<Unidoc.LookupAdjacent> = .init("\(package):0.2.0", [])
            let output:Unidoc.VertexOutput = try #require(try await db.query(with: query))

            #expect(output.canonicalVolume?.patch == .v(0, 2, 0))
            #expect(output.principalVolume.patch == .v(0, 2, 0))
            #expect(output.principalVertex?.landing != nil)
        }

        do
        {
            /// We should be able to resolve version 0.1.0 with a symbolic volume query.
            let query:Unidoc.VertexQuery<Unidoc.LookupAdjacent> = .init("\(package):0.1.0", [])
            let output:Unidoc.VertexOutput = try #require(try await db.query(with: query))

            #expect(output.canonicalVolume?.patch == .v(0, 2, 0))
            #expect(output.principalVolume.patch == .v(0, 1, 0))
            #expect(output.principalVertex?.landing != nil)
        }

        do
        {
            /// We should be able to resolve version 1.0.0 with a symbolic volume query.
            let query:Unidoc.VertexQuery<Unidoc.LookupAdjacent> = .init("\(package):1.0.0", [])
            let output:Unidoc.VertexOutput = try #require(try await db.query(with: query))

            #expect(output.canonicalVolume?.patch == .v(0, 2, 0))
            #expect(output.principalVolume.patch == nil)
            #expect(output.principalVolume.refname == "1.0.0-beta.1")
            #expect(output.principalVertex?.landing != nil)
        }
    }
}
