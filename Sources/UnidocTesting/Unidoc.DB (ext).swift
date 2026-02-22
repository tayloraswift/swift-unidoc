import SymbolGraphs
import UnidocAPI
import UnidocDB
import UnidocLinker

extension Unidoc.DB {
    /// Indexes and stores a symbol graph in the database, linking it **synchronously**.
    public func store(
        linking docs: SymbolGraphObject<Void>
    ) async throws -> (Unidoc.UploadStatus, Unidoc.UplinkStatus) {
        let package: Unidoc.PackageMetadata
        let edition: Unidoc.EditionMetadata

        (package, edition) = try await self.label(docs: docs.metadata)

        //  Don’t queue for uplink, since we’re going to do that synchronously.
        let snapshot: Unidoc.Snapshot = .init(
            id: edition.id,
            metadata: docs.metadata,
            inline: docs.graph,
            action: nil
        )

        let uploaded: Unidoc.UploadStatus = try await self.snapshots.store(
            snapshot: snapshot
        )

        let uplinked: Unidoc.UplinkStatus = try await self.uplink(
            snapshot: snapshot,
            package: package,
            linker: .dynamic,
            loader: .inline
        )

        return (uploaded, uplinked)
    }

    /// Indexes and stores a symbol graph in the database, queueing it for an **asynchronous**
    /// uplink.
    public func store(
        docs: consuming SymbolGraphObject<Void>
    ) async throws -> Unidoc.UploadStatus {
        let (_, edition): (_, Unidoc.EditionMetadata) = try await self.label(
            docs: docs.metadata
        )

        let snapshot: Unidoc.Snapshot = .init(
            id: edition.id,
            metadata: docs.metadata,
            inline: docs.graph,
            action: .uplink
        )

        return try await self.snapshots.store(snapshot: snapshot)
    }
}
