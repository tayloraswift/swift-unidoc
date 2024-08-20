import BSON
import HTTP
import HTTPServer
import JSON
import MongoDB
import S3
import S3Client
import SymbolGraphs
import UnidocDB
import UnidocRecords

extension Unidoc
{
    struct BuilderUploadOperation:Sendable
    {
        let route:Unidoc.BuildRoute

        init(route:Unidoc.BuildRoute)
        {
            self.route = route
        }
    }
}
extension Unidoc.BuilderUploadOperation:Unidoc.BlockingOperation
{
    func perform(with payload:[UInt8],
        on server:Unidoc.Server,
        db:Unidoc.DB) async throws -> HTTP.ServerResponse
    {
        let bson:BSON.Document = .init(bytes: payload[...])

        switch self.route
        {
        case .report:
            let report:Unidoc.BuildReport = try .init(bson: bson)
            try await db.packageBuilds.updateBuild(
                package: report.package,
                entered: report.entered)

        case .labeled:
            var artifact:Unidoc.BuildArtifact = try .init(bson: bson)
            let logs:[Unidoc.BuildLogType]

            switch artifact.outcome
            {
            case .failure(let reason):
                logs = try await artifact.export(from: server)
                try await db.packageBuilds.finishBuild(
                    package: artifact.package,
                    failure: reason,
                    logs: logs)

            case .success(let snapshot):
                /// A successful (labeled) build also sets the platform preference, since we now
                /// know that the package can be built on that platform.
                let _metadata:Unidoc.PackageMetadata? = try await db.packages.reset(
                    platformPreference: snapshot.metadata.triple,
                    of: snapshot.id.package)

                /// Right now, exporting build logs for private repositories is a security
                /// hazard, because the logs contain secrets, and the log URLs are easily
                /// predicted. For now, we just discard the logs for private repositories.
                let _logsIncluded:Bool
                if  case true? = _metadata?.repo?.private
                {
                    _logsIncluded = false
                }
                else
                {
                    _logsIncluded = true
                }

                logs = try await artifact.export(from: server, _logsIncluded: _logsIncluded)

                try await db.packageBuilds.finishBuild(
                    package: artifact.package,
                    failure: nil,
                    logs: logs)

                let _:Unidoc.UploadStatus = try await db.snapshots.upsert(snapshot: snapshot)
            }

        case .labeling:
            let documentation:SymbolGraphObject<Void> = try .init(bson: bson)

            var (snapshot, _):(Unidoc.Snapshot, _?) = try await db.label(
                documentation: documentation,
                //  This is probably the standard library, or some other ‘special’ package, so
                //  we don’t want it to appear in the activity feed.
                action: .uplinkRefresh)

            if  let bucket:AWS.S3.Bucket = server.bucket.graphs
            {
                let s3:AWS.S3.Client = .init(threads: server.context.threads,
                    niossl: server.context.niossl,
                    bucket: bucket)

                try await snapshot.moveSymbolGraph(to: s3)
            }

            try await db.packageBuilds.finishBuild(package: snapshot.id.package)

            let _:Unidoc.UploadStatus = try await db.snapshots.upsert(snapshot: snapshot)
        }

        return .noContent
    }
}
