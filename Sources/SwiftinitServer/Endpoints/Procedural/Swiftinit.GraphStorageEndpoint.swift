import BSON
import HTTP
import MongoDB
import S3
import S3Client
import UnidocDB
import UnidocRecords

extension Swiftinit
{
    /// See ``GraphPlacementEndpoint``.
    enum GraphStorageEndpoint:Sendable
    {
        case put
    }
}
extension Swiftinit.GraphStorageEndpoint:BlockingEndpoint
{
    func perform(on server:borrowing Swiftinit.Server,
        payload:consuming [UInt8],
        session:Mongo.Session) async throws -> HTTP.ServerResponse
    {
        switch self
        {
        case .put:
            var snapshot:Unidoc.Snapshot = try .init(
                bson: BSON.DocumentView<[UInt8]>.init(slice: payload))

            if  let bucket:AWS.S3.Bucket = server.bucket,
                let bson:[UInt8] = snapshot.move()
            {
                let s3:AWS.S3.Client = .init(threads: server.context.threads,
                    niossl: server.context.niossl,
                    bucket: bucket)
                try await s3.connect
                {
                    try await $0.put(bson,
                        using: .standard,
                        path: "\(snapshot.path)",
                        type: .application(.bson))
                }
            }

            let uploaded:Unidoc.UploadStatus = try await server.db.snapshots.upsert(
                snapshot: snapshot,
                with: session)

            return .ok(uploaded.updated ? "Updated" : "Inserted")
        }
    }
}
