import UnidocDB

extension Unidoc.DB.Snapshots {
    func store(snapshot: Unidoc.Snapshot) async throws -> Unidoc.UploadStatus {
        switch try await self.upsert(snapshot) {
        case nil:   .init(edition: snapshot.id, updated: true)
        case  _?:   .init(edition: snapshot.id, updated: false)
        }
    }
}
