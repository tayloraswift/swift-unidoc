import BSON
import HTTP
import HTTPServer
import JSON
import LZ77
import MongoDB
import S3
import S3Client
import SymbolGraphs
import UnidocDB
import UnidocRecords
import UnixTime

extension Unidoc {
    struct BuilderUploadOperation: Sendable {
        let route: Unidoc.BuildRoute

        init(route: Unidoc.BuildRoute) {
            self.route = route
        }
    }
}
extension Unidoc.BuilderUploadOperation: Unidoc.BlockingOperation {
    func perform(
        with payload: [UInt8],
        on server: Unidoc.Server,
        db: Unidoc.DB
    ) async throws -> HTTP.ServerResponse {
        let bson: BSON.Document = .init(bytes: payload[...])

        switch self.route {
        case .artifact:
            let artifact: Unidoc.BuildArtifact = try .init(bson: bson)
            return try await self.ingest(artifact: artifact, on: server, db: db)

        case .report:
            let report: Unidoc.BuildReport = try .init(bson: bson)
            try await db.pendingBuilds.updateBuild(id: report.edition, entered: report.entered)
            return .noContent
        }
    }

    func ingest(
        artifact build: Unidoc.BuildArtifact,
        on server: Unidoc.Server,
        db: Unidoc.DB
    ) async throws -> HTTP.ServerResponse {
        let payload: Unidoc.BuildPayload
        let label: Unidoc.Edition
        if  let id: Unidoc.Edition = build.edition {
            guard
            let pending: Unidoc.PendingBuild = try await db.pendingBuilds.finishBuild(id: id),
            let launched: UnixMillisecond = pending.launched else {
                return .notFound("Build not found or timed-out\n")
            }

            let duration: Seconds = .seconds(build.seconds)
            let finished: UnixMillisecond = launched.advanced(by: .init(duration))

            /// The logs are secret if the builder indicated that they are.
            ///
            /// Log secrecy is on a per-build basis, so that repositories can be made public
            /// without accidentally exposing sensitive logs from the past.
            ///
            /// Log secrecy is determined when the build starts, not when it finishes, to
            /// avoid leaking secrets if a repository is made public while a build is running.
            var complete: Unidoc.CompleteBuild = .init(
                id: .init(
                    edition: pending.id,
                    run: pending.run
                ),
                launched: launched,
                finished: finished,
                failure: build.failure,
                name: pending.name,
                logs: [],
                logsAreSecret: build.logsAreSecret
            )

            complete.logs = try await build.exportLogs(as: complete.id, from: server)

            try await db.completeBuilds.upsert(complete)

            guard case .success(let labeled) = build.outcome else {
                //  Mark the snapshot as unbuildable, so that automated plugins don’t try to
                //  build it again.
                try await db.snapshots.mark(id: id, vintage: true)
                return .noContent
            }

            /// A successful (labeled) build also sets the platform preference, since we now
            /// know that the package can be built on that platform.
            let _: Unidoc.PackageMetadata? = try await db.packages.modify(id: id.package) {
                $0[.set] {
                    $0[Unidoc.PackageMetadata[.build_platform]] = labeled.metadata.triple
                }
            }

            payload = labeled
            label = id
        } else {
            guard case .success(let unlabeled) = build.outcome else {
                return .resource("Cannot label unsuccessful build artifact\n", status: 400)
            }

            let (_, edition): (_, Unidoc.EditionMetadata) = try await db.label(
                docs: unlabeled.metadata
            )

            payload = unlabeled
            label = edition.id
        }

        let snapshot: Unidoc.Snapshot

        if  let bucket: AWS.S3.Bucket = server.bucket.graphs {
            let s3: AWS.S3.Client = .init(
                threads: .singleton,
                niossl: server.clientIdentity,
                bucket: bucket
            )

            snapshot = .init(
                id: label,
                metadata: payload.metadata,
                inline: nil,
                action: .uplink,
                type: .bson_zz,
                size: payload.size
            )

            try await s3.connect {
                try await $0.put(
                    object: .init(body: .binary(payload.zlib), type: .application(.bson)),
                    using: .standard,
                    path: "\(snapshot.path)"
                )
            }
        } else {
            var inflator: LZ77.Inflator = .init(format: .zlib)
            try inflator.push(payload.zlib)

            let bson: BSON.Document = .init(bytes: inflator.pull()[...])

            snapshot = .init(
                id: label,
                metadata: payload.metadata,
                inline: try .init(bson: bson),
                action: .uplink
            )
        }

        try await db.snapshots.upsert(snapshot)
        return .noContent
    }
}
