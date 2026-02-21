import BSON
import SymbolGraphs
import Symbols

extension Unidoc.GraphLoader {
    /// Wraps and returns the inline symbol graph from the snapshot if present, invokes the
    /// ``load(graph:)`` witness and parses the returned buffer otherwise.
    func load(_ snapshot: Unidoc.Snapshot) async throws -> SymbolGraphObject<Unidoc.Edition> {
        if  let inline: SymbolGraph = snapshot.inline {
            return .init(metadata: snapshot.metadata, graph: inline, id: snapshot.id)
        } else {
            let bytes: ArraySlice<UInt8> = try await self.load(graph: snapshot.path)
            let graph: SymbolGraph = try .init(bson: BSON.Document.init(bytes: bytes))

            return .init(metadata: snapshot.metadata, graph: graph, id: snapshot.id)
        }
    }

    func load(
        dependencies pins: [Unidoc.EditionMetadata?],
        of metadata: SymbolGraphMetadata,
        in snapshots: Unidoc.DB.Snapshots
    ) async throws -> [SymbolGraphObject<Unidoc.Edition>] {
        let exonyms: [Unidoc.Edition: Symbol.Package] = metadata.exonyms(pins: pins)
        var objects: [SymbolGraphObject<Unidoc.Edition>] = []
        objects.reserveCapacity(1 + exonyms.count)

        if  metadata.package.name != .swift,
            let swift: Unidoc.Snapshot = try await snapshots.findStandardLibrary(
                hint: metadata.swift.version
            ) {
            objects.append(try await self.load(swift))
        }

        for other: Unidoc.Snapshot in try await snapshots.findAll(of: exonyms.keys.sorted()) {
            var object: SymbolGraphObject<Unidoc.Edition> = try await self.load(other)
            if  let exonym: Symbol.Package = exonyms[other.id] {
                object.metadata.package.name = exonym
                object.metadata.package.scope = nil
            }
            objects.append(object)
        }

        let missing: [Unidoc.Edition: Symbol.Package] = objects.reduce(into: exonyms) {
            $0[$1.id] = nil
        }
        for missing: Symbol.Package in missing.values.sorted() {
            print("""
                warning: could not load pinned dependency '\(missing)' for \
                snapshot '\(metadata.package.name)'
                """)
        }

        return objects
    }
}
