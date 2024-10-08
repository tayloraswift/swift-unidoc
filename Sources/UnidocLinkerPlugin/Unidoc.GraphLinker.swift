import MongoDB
import S3Client
import UnidocDB
import UnidocServer

extension Unidoc
{
    @frozen public
    struct GraphLinker
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
extension Unidoc.GraphLinker:Unidoc.Plugin
{
    @inlinable public
    static var title:String { "Linker" }
    @inlinable public
    static var id:String { "linker" }

    public
    func run(in context:Unidoc.PluginContext<Event>) async throws -> Duration?
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
extension Unidoc.GraphLinker
{
    private
    func perform(operation:Unidoc.DB.Snapshots.QueuedOperation,
        with graphs:AWS.S3.Client?,
        in context:Unidoc.PluginContext<Event>) async throws
    {
        let event:Event?

        action:
        switch operation.action
        {
        case .uplink:
            guard
            let status:Unidoc.UplinkStatus = try await context.db.uplink(operation.edition,
                from: graphs)
            else
            {
                event = nil
                break
            }

            if !status.hidden
            {
                _ = try await context.db.docsFeed.push(.init(
                        discovered: .now(),
                        volume: status.edition))
            }

            event = .uplinked(status)

        case .unlink:
            let status:Unidoc.UnlinkStatus? = try await context.db.unlink(operation.edition)

            event = status.map(Event.unlinked(_:))

        case .delete:
            //  Okay if the volume has already been unlinked, which causes this to return nil.
            if  let unlink:Unidoc.UnlinkStatus = try await context.db.unlink(operation.edition)
            {
                switch unlink
                {
                case .declined(let id):
                    event = .unlinked(.declined(id))
                    break action

                case .unlinked(let id):
                    context.log(event: .unlinked(.unlinked(id)))
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
                    event = nil
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

            if  try await context.db.snapshots.delete(id: operation.edition)
            {
                event = .deleted(.deleted(operation.edition, fromS3: deletedS3))
            }
            else
            {
                event = nil
            }
        }

        try await context.db.snapshots.clear(id: operation.edition)

        if  let event:Event
        {
            context.log(event: event)
        }
        else
        {
            context.log(event: .failed(operation.edition, action: operation.action))
        }
    }
}
