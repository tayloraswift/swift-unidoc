import BSON
import HTTP
import JSON
import MongoDB
import S3
import S3Client
import SymbolGraphs
import UnidocDB
import UnidocRecords

extension Swiftinit
{
    struct BuilderUploadEndpoint:Sendable
    {
        let outcome:Unidoc.BuildOutcome

        init(outcome:Unidoc.BuildOutcome)
        {
            self.outcome = outcome
        }
    }
}
extension Swiftinit.BuilderUploadEndpoint:Swiftinit.BlockingEndpoint
{
    func perform(on server:borrowing Swiftinit.Server,
        payload:__owned [UInt8],
        session:Mongo.Session) async throws -> HTTP.ServerResponse
    {
        let bson:BSON.Document = .init(bytes: payload[...])
        let json:JSON?

        let package:Unidoc.Package
        let failure:Unidoc.BuildFailure?

        switch self.outcome
        {
        case .failure:
            let report:Unidoc.BuildFailureReport = try .init(bson: bson)

            package = report.package
            failure = report.failure

            json = nil

        case .success:
            var snapshot:Unidoc.Snapshot = try .init(bson: bson)

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

            package = uploaded.package
            failure = nil

            json = .encode(uploaded)

        case .successUnlabeled:
            let documentation:SymbolGraphObject<Void> = try .init(bson: bson)

            var (snapshot, _):(Unidoc.Snapshot, _?) = try await server.db.unidoc.label(
                documentation: documentation,
                //  This is probably the standard library, or some other ‘special’ package, so
                //  we don’t want it to appear in the activity feed.
                action: .uplinkRefresh,
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

            package = uploaded.package
            failure = nil

            json = .encode(uploaded)
        }

        let _:Unidoc.BuildMetadata? = try await server.db.packageBuilds.finishBuild(
            package: package,
            failure: failure,
            with: session)

        if  let json:JSON = json
        {
            return .ok(.init(content: .binary(json.utf8),
                type: .application(.json, charset: .utf8),
                gzip: false))
        }
        else
        {
            return .noContent
        }
    }
}
