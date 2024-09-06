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
import UnixTime

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
            try await db.pendingBuilds.updateBuild(id: report.edition, entered: report.entered)

        case .labeled:
            var build:Unidoc.BuildArtifact = try .init(bson: bson)

            guard
            let pending:Unidoc.PendingBuild = try await db.pendingBuilds.finishBuild(
                id: build.edition),
            let launched:UnixMillisecond = pending.launched
            else
            {
                return .notFound("Build not found or timed-out\n")
            }

            let duration:Seconds = .seconds(build.seconds)
            let finished:UnixMillisecond = launched.advanced(by: .init(duration))

            var complete:Unidoc.CompleteBuild = .init(edition: build.edition,
                launched: launched,
                finished: finished,
                failure: build.failure,
                name: pending.name,
                logs: [])

            complete.logs = try await build.export(as: complete.id, from: server)

            try await db.completeBuilds.upsert(complete)

            if  case .success(let snapshot) = build.outcome
            {
                try await db.snapshots.upsert(snapshot)

                /// A successful (labeled) build also sets the platform preference, since we now
                /// know that the package can be built on that platform.
                let _:Unidoc.PackageMetadata? = try await db.packages.reset(
                    platformPreference: snapshot.metadata.triple,
                    of: snapshot.id.package)
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

            try await db.snapshots.upsert(snapshot)
        }

        return .noContent
    }
}
