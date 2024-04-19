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
    func perform(on server:borrowing Unidoc.Server,
        payload:__owned [UInt8],
        session:Mongo.Session) async throws -> HTTP.ServerResponse
    {
        let bson:BSON.Document = .init(bytes: payload[...])
        let uploaded:Unidoc.UploadStatus

        switch self.route
        {
        case .report:
            let report:Unidoc.BuildReport = try .init(bson: bson)

            if  let stage:Unidoc.BuildStage = report.entered
            {
                try await server.db.packageBuilds.updateBuild(
                    package: report.package,
                    entered: stage,
                    with: session)
            }
            else
            {
                let logs:[Unidoc.BuildLogType] = try await self.export(report: report,
                    from: server)

                try await server.db.packageBuilds.finishBuild(
                    package: report.package,
                    failure: report.failure,
                    logs: logs,
                    with: session)
            }

            return .noContent

        case .labeled:
            var snapshot:Unidoc.Snapshot = try .init(bson: bson)

            /// A successful (labeled) build also sets the platform preference, since we now
            /// know that the package can be built on that platform.
            let _:Bool? = try await server.db.packages.update(package: snapshot.id.package,
                platformPreference: snapshot.metadata.triple,
                with: session)

            if  let bucket:AWS.S3.Bucket = server.bucket.graphs
            {
                let s3:AWS.S3.Client = .init(threads: server.context.threads,
                    niossl: server.context.niossl,
                    bucket: bucket)

                try await snapshot.moveSymbolGraph(to: s3)
            }

            uploaded = try await server.db.snapshots.upsert(
                snapshot: snapshot,
                with: session)

        case .labeling:
            let documentation:SymbolGraphObject<Void> = try .init(bson: bson)

            var (snapshot, _):(Unidoc.Snapshot, _?) = try await server.db.unidoc.label(
                documentation: documentation,
                //  This is probably the standard library, or some other ‘special’ package, so
                //  we don’t want it to appear in the activity feed.
                action: .uplinkRefresh,
                with: session)

            if  let bucket:AWS.S3.Bucket = server.bucket.graphs
            {
                let s3:AWS.S3.Client = .init(threads: server.context.threads,
                    niossl: server.context.niossl,
                    bucket: bucket)

                try await snapshot.moveSymbolGraph(to: s3)
            }

            uploaded = try await server.db.unidoc.snapshots.upsert(
                snapshot: snapshot,
                with: session)
        }

        /// The symbol graph upload and the final build report are not necessarily sequentially
        /// consistent, so we need to avoid accidentally clearing the logs if the build report
        /// is written before the symbol graph upload.
        try await server.db.packageBuilds.finishBuild(package: uploaded.package, with: session)
        let json:JSON = .encode(uploaded)

        return .ok(.init(content: .init(
            body: .binary(json.utf8),
            type: .application(.json, charset: .utf8))))
    }
}
extension Unidoc.BuilderUploadOperation
{
    private
    func export(report:Unidoc.BuildReport,
        from server:borrowing Unidoc.Server) async throws -> [Unidoc.BuildLogType]
    {
        var logs:[Unidoc.BuildLogType] = []

        let logsToExport:Int = report.logs.count
        if  logsToExport > 0
        {
            guard
            let bucket:AWS.S3.Bucket = server.bucket.assets
            else
            {
                Log[.warning] = "No destination bucket configured for exporting build logs!"
                return []
            }

            logs.reserveCapacity(logsToExport)

            let s3:AWS.S3.Client = .init(threads: server.context.threads,
                niossl: server.context.niossl,
                bucket: bucket)

            try await s3.connect
            {
                for log:Unidoc.BuildLog in report.logs
                {
                    let path:Unidoc.BuildLogPath = .init(package: report.package,
                        type: log.type)

                    try await $0.put(object: .init(
                            body: .binary(log.text.bytes),
                            type: .text(.plain, charset: .utf8),
                            encoding: .gzip),
                        using: .standard,
                        path: "\(path)")

                    logs.append(log.type)
                }
            }
        }

        return logs
    }
}
