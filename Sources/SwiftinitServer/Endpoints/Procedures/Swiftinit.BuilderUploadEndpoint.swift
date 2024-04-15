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

extension Swiftinit
{
    struct BuilderUploadEndpoint:Sendable
    {
        let route:Unidoc.BuildRoute

        init(route:Unidoc.BuildRoute)
        {
            self.route = route
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
        let entered:Unidoc.BuildStage?
        var logs:[Unidoc.BuildLogType] = []

        switch self.route
        {
        case .report:
            let report:Unidoc.BuildReport = try .init(bson: bson)

            package = report.package
            entered = report.entered
            failure = report.failure

            json = nil

            let logsToExport:Int = report.logs.count
            if  logsToExport > 0
            {
                guard
                let bucket:AWS.S3.Bucket = server.bucket.assets
                else
                {
                    Log[.warning] = "No destination bucket configured for exporting build logs!"
                    break
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

                        try await $0.put(content: .init(
                                body: .binary(log.text.bytes),
                                type: .text(.plain, charset: .utf8),
                                encoding: .gzip),
                            using: .standard,
                            path: "\(path)")

                        logs.append(log.type)
                    }
                }
            }

        case .labeled:
            var snapshot:Unidoc.Snapshot = try .init(bson: bson)

            if  let bucket:AWS.S3.Bucket = server.bucket.graphs
            {
                let s3:AWS.S3.Client = .init(threads: server.context.threads,
                    niossl: server.context.niossl,
                    bucket: bucket)

                try await snapshot.moveSymbolGraph(to: s3)
            }

            let uploaded:Unidoc.UploadStatus = try await server.db.snapshots.upsert(
                snapshot: snapshot,
                with: session)

            package = uploaded.package
            entered = nil
            failure = nil

            json = .encode(uploaded)

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

            let uploaded:Unidoc.UploadStatus = try await server.db.unidoc.snapshots.upsert(
                snapshot: snapshot,
                with: session)

            package = uploaded.package
            entered = nil
            failure = nil

            json = .encode(uploaded)
        }

        /// The symbol graph upload and the final build report are not necessarily sequentially
        /// consistent, so we need to avoid accidentally clearing the logs if the build report
        /// is written before the symbol graph upload.
        let _:Unidoc.BuildMetadata? = try await server.db.packageBuilds.updateBuild(
            package: package,
            entered: entered,
            failure: failure,
            logs: logs.isEmpty ? nil : logs,
            with: session)

        if  let json:JSON = json
        {
            return .ok(.init(content: .init(
                body: .binary(json.utf8),
                type: .application(.json, charset: .utf8))))
        }
        else
        {
            return .noContent
        }
    }
}
