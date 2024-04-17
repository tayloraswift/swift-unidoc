import MongoDB
import S3Client
import UnidocDB
import UnidocServer

extension Swiftinit
{
    struct Linker
    {
        private
        let status:AtomicPointer<Unidoc.CollectionEventsPage<Self>>
        private
        let graphs:AWS.S3.Client?
        private
        var buffer:Unidoc.EventBuffer<Event>

        init(updating status:AtomicPointer<Unidoc.CollectionEventsPage<Self>>,
            graphs:AWS.S3.Client?)
        {
            self.status = status
            self.graphs = graphs
            self.buffer = .init(minimumCapacity: 100)
        }
    }
}
extension Swiftinit.Linker:Unidoc.CollectionVisitor
{
    static
    var title:String { "Linker" }

    mutating
    func publish(event:Event)
    {
        self.buffer.push(event: event)
        self.publish()
    }

    func publish()
    {
        self.status.replace(value: .init(from: self.buffer))
    }

    mutating
    func tour(in db:Unidoc.DB, with session:Mongo.Session) async throws
    {
        while true
        {
            //  This prevents us from spinning when there are no editions to uplink.
            async
            let cooldown:Void = Task.sleep(for: .seconds(5))

            for queued:Unidoc.DB.Snapshots.QueuedOperation in try await db.snapshots.pending(8,
                with: session)
            {
                async
                let cooldown:Void = Task.sleep(for: .seconds(5))

                try await self.perform(operation: queued,
                    updating: db,
                    with: session)

                try await cooldown
            }

            try await cooldown
        }
    }
}
extension Swiftinit.Linker
{
    private mutating
    func perform(operation:Unidoc.DB.Snapshots.QueuedOperation,
        updating unidoc:Unidoc.DB,
        with session:Mongo.Session) async throws
    {
        defer
        {
            self.publish()
        }

        let event:Event?

        action:
        switch operation.action
        {
        case .uplinkInitial, .uplinkRefresh:
            let status:Unidoc.UplinkStatus? = try await self.uplink(snapshot: operation.edition,
                updating: unidoc,
                with: session)

            event = status.map(Event.uplinked(_:))

        case .unlink:
            let status:Unidoc.UnlinkStatus? = try await unidoc.unlink(operation.edition,
                with: session)

            event = status.map(Event.unlinked(_:))

        case .delete:
            //  Okay if the volume has already been unlinked, which causes this to return nil.
            if  let unlink:Unidoc.UnlinkStatus = try await unidoc.unlink(operation.edition,
                    with: session)
            {
                switch unlink
                {
                case .declined(let id):
                    event = .unlinked(.declined(id))
                    break action

                case .unlinked(let id):
                    self.buffer.push(event: .unlinked(.unlinked(id)))
                }
            }

            let path:Unidoc.GraphPath = .init(edition: operation.edition,
                type: operation.graphType)

            let deletedS3:Bool
            if  operation.graphSize > 0
            {
                //  There is almost certainly an S3 graph to delete.
                guard
                let graphs:AWS.S3.Client = self.graphs
                else
                {
                    event = nil
                    break action
                }

                deletedS3 = try await graphs.connect { try await $0.delete(path: "\(path)") }
            }
            else if
                let graphs:AWS.S3.Client = self.graphs
            {
                //  There might be an S3 graph to delete.
                deletedS3 = try await graphs.connect { try await $0.delete(path: "\(path)") }
            }
            else
            {
                //  We cannot delete any S3 graphs.
                deletedS3 = false
            }

            if  try await unidoc.snapshots.delete(id: operation.edition,  with: session)
            {
                event = .deleted(.deleted(operation.edition, fromS3: deletedS3))
            }
            else
            {
                event = nil
            }
        }

        try await session.update(database: unidoc.id,
            with: Unidoc.DB.Snapshots.ClearAction.one(operation.edition))

        if  let event:Event
        {
            self.buffer.push(event: event)
        }
        else
        {
            self.buffer.push(event: .failed(operation.edition, action: operation.action))
        }
    }

    private
    func uplink(snapshot id:Unidoc.Edition,
        updating unidoc:Unidoc.DB,
        with session:Mongo.Session) async throws -> Unidoc.UplinkStatus?
    {
        guard
        let status:Unidoc.UplinkStatus = try await unidoc.uplink(id,
            from: self.graphs,
            with: session)
        else
        {
            return nil
        }

        if !status.hidden
        {
            _ = try await unidoc.docsFeed.push(.init(
                    discovered: .now(),
                    volume: status.edition),
                with: session)
        }

        return status
    }
}
