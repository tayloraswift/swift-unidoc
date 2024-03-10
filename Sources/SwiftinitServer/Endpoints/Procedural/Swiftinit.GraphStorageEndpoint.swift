import BSON
import HTTP
import JSON
import LZ77
import MongoDB
import S3
import S3Client
import SymbolGraphs
import UnidocDB
import UnidocRecords

extension Swiftinit
{
    enum GraphStorageEndpoint:Sendable
    {
        case placed
        case object
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
        case .placed:
            var snapshot:Unidoc.Snapshot = try .init(
                bson: BSON.Document.init(bytes: payload[...]))

            if  let bucket:AWS.S3.Bucket = server.bucket
            {
                let s3:AWS.S3.Client = .init(threads: server.context.threads,
                    niossl: server.context.niossl,
                    bucket: bucket)

                try await snapshot.move(to: s3)
            }

            let uploaded:Unidoc.UploadStatus = try await server.db.snapshots.upsert(
                snapshot: snapshot,
                with: session)

            return .ok(uploaded.updated ? "Updated" : "Inserted")

        case .object:
            let documentation:SymbolGraphObject<Void> = try .init(
                bson: BSON.Document.init(bytes: payload[...]))

            var (snapshot, _):(Unidoc.Snapshot, _?) = try await server.db.unidoc.label(
                documentation: documentation,
                action: .uplinkInitial,
                with: session)

            if  let bucket:AWS.S3.Bucket = server.bucket
            {
                let s3:AWS.S3.Client = .init(threads: server.context.threads,
                    niossl: server.context.niossl,
                    bucket: bucket)

                try await snapshot.move(to: s3)
            }

            let uploaded:Unidoc.UploadStatus = try await server.db.unidoc.snapshots.upsert(
                snapshot: snapshot,
                with: session)

            let json:JSON = .encode(uploaded)

            return .ok(.init(content: .binary(json.utf8),
                type: .application(.json, charset: .utf8),
                gzip: false))
        }
    }
}
