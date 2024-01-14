import MongoDB
import SwiftinitPlugins
import UnidocDB

extension Swiftinit
{
    struct Linker
    {
        private
        let status:AtomicPointer<LinkerPlugin.StatusPage>
        private
        var buffer:Swiftinit.EventBuffer<Event>

        init(updating status:AtomicPointer<LinkerPlugin.StatusPage>)
        {
            self.status = status
            self.buffer = .init(minimumCapacity: 100)
        }
    }
}
extension Swiftinit.Linker
{
    private
    func publish()
    {
        status.replace(value: .init(from: self.buffer))
    }
}
extension Swiftinit.Linker
{
    mutating
    func watch(_ db:Swiftinit.DB) async throws
    {
        //  Otherwise the page will be empty until something is queued.
        self.publish()

        while true
        {
            //  If we caught an error, it was probably because mongod is restarting.
            //  We should wait a little while for it to come back online.
            async
            let cooldown:Void = Task.sleep(for: .seconds(5))

            do
            {
                let session:Mongo.Session = try await .init(from: db.sessions)
                try await self.tour(watching: db, with: session)
            }
            catch let error
            {
                self.buffer.push(event: .caught(error))
                self.publish()
            }

            try await cooldown
        }
    }

    private mutating
    func tour(watching db:Swiftinit.DB, with session:Mongo.Session) async throws
    {
        while true
        {
            //  This prevents us from spinning when there are no editions to uplink.
            async
            let cooldown:Void = Task.sleep(for: .seconds(5))

            for edition:Unidoc.Edition in try await db.snapshots.linkable(8,
                with: session)
            {
                async
                let cooldown:Void = Task.sleep(for: .seconds(5))

                try await self.uplink(snapshot: edition,
                    updating: db,
                    with: session)

                try await cooldown
            }

            try await cooldown
        }
    }

    private mutating
    func uplink(snapshot edition:Unidoc.Edition,
        updating db:Swiftinit.DB,
        with session:Mongo.Session) async throws
    {
        defer
        {
            self.publish()
        }

        guard
        let status:Unidoc.UplinkStatus = try await db.unidoc.uplink(edition,
            with: session)
        else
        {
            self.buffer.push(event: .failed(edition))
            return
        }

        try await session.update(database: db.unidoc.id,
            with: UnidocDatabase.Snapshots.ClearUplink.one(edition))

        self.buffer.push(event: .uplinked(status))

        if  status.hidden
        {
            return
        }

        _ = try await db.docsFeed.push(.init(
                    discovered: .now(),
                    volume: status.edition),
                with: session)
    }
}
