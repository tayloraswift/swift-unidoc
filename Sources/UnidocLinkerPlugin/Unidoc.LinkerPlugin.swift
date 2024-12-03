import MongoDB
import S3Client
import UnidocDB
import UnidocServer

extension Unidoc
{
    @frozen public
    struct LinkerPlugin
    {
        @usableFromInline
        let bucket:AWS.S3.Bucket?

        @inlinable public
        init(bucket:AWS.S3.Bucket?)
        {
            self.bucket = bucket
        }
    }
}
extension Unidoc.LinkerPlugin:Unidoc.Plugin
{
    @inlinable public
    static var title:String { "Linker" }
    @inlinable public
    static var id:String { "linker" }

    public
    func run(in context:Unidoc.PluginContext) async throws -> Duration?
    {
        let graphs:AWS.S3.Client? = self.bucket.map
        {
            .init(threads: .singleton, niossl: context.client, bucket: $0)
        }
        for queued:Unidoc.DB.Snapshots.QueuedOperation
            in try await context.db.snapshots.pending(8)
        {
            async
            let cooldown:Void = Task.sleep(for: .seconds(5))

            try await self.perform(operation: queued, with: graphs, in: context)

            try await cooldown
        }

        return nil
    }
}
extension Unidoc.LinkerPlugin
{
    private
    func perform(operation:Unidoc.DB.Snapshots.QueuedOperation,
        with graphs:AWS.S3.Client?,
        in context:Unidoc.PluginContext) async throws
    {
        action:
        switch operation.action
        {
        case .uplink:
            guard
            let status:Unidoc.UplinkStatus = try await context.db.uplink(operation.edition,
                s3: graphs)
            else
            {
                context.log(failed: operation.action, id: operation.edition)
                break
            }

            if !status.hidden
            {
                _ = try await context.db.docsFeed.push(.init(
                        discovered: .now(),
                        volume: status.edition))
            }

            context.log(uplinked: status)

        case .unlink:
            guard
            let status:Unidoc.UnlinkStatus = try await context.db.unlink(operation.edition)
            else
            {
                context.log(failed: operation.action, id: operation.edition)
                break
            }

            context.log(unlinked: status)

        case .delete:
            //  Okay if the volume has already been unlinked, which causes this to return nil.
            if  let unlink:Unidoc.UnlinkStatus = try await context.db.unlink(operation.edition)
            {
                switch unlink
                {
                case .declined(let id):
                    context.log(unlinked: .declined(id))
                    break action

                case .unlinked(let id):
                    context.log(unlinked: .unlinked(id))
                }
            }

            let path:Unidoc.GraphPath = .init(edition: operation.edition,
                type: operation.graphType)

            let deletedS3:Bool
            if  operation.graphSize > 0
            {
                //  There is almost certainly an S3 graph to delete.
                guard
                let graphs:AWS.S3.Client
                else
                {
                    context.log(failed: operation.action, id: operation.edition)
                    break action
                }

                deletedS3 = try await graphs.connect { try await $0.delete(path: "\(path)") }
            }
            else if
                let graphs:AWS.S3.Client
            {
                //  There might be an S3 graph to delete.
                deletedS3 = try await graphs.connect { try await $0.delete(path: "\(path)") }
            }
            else
            {
                //  We cannot delete any S3 graphs.
                deletedS3 = false
            }

            guard try await context.db.snapshots.delete(id: operation.edition)
            else
            {
                context.log(failed: operation.action, id: operation.edition)
                break action
            }

            context.log(deleted: .deleted(operation.edition, fromS3: deletedS3))
        }

        try await context.db.snapshots.clear(id: operation.edition)
    }
}
