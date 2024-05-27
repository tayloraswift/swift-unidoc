import BSON
import MongoDB

extension Unidoc
{
    public final
    actor GraphStateLoop
    {
        private
        let pollingInterval:Duration

        private
        let cancellations:AsyncStream<UInt>.Continuation
        private
        var subscribers:[UInt: Subscriber]
        private
        var counter:UInt

        private
        var clusterTime:BSON.Timestamp?

        private
        init(cancellations:AsyncStream<UInt>.Continuation)
        {
            self.pollingInterval = .seconds(30)

            self.cancellations = cancellations
            self.subscribers = [:]
            self.counter = 0

            self.clusterTime = nil
        }

        deinit
        {
            for subscriber:Subscriber in self.subscribers.values
            {
                subscriber.continuation.resume(throwing: CancellationError.init())
            }
        }
    }
}
extension Unidoc.GraphStateLoop
{
    public static
    func run<T>(watching db:Unidoc.Database,
        with body:(Unidoc.GraphStateLoop) async throws -> T) async rethrows -> T
    {
        let continuation:AsyncStream<UInt>.Continuation
        let stream:AsyncStream<UInt>

        (stream, continuation) = AsyncStream<UInt>.makeStream()

        let loop:Self = .init(cancellations: continuation)

        async
        let _:Void = loop.watch(db: db)

        async
        let cleanup:Void = loop.cleanup(cancelled: stream)
        let success:T
        do
        {
            success = try await body(loop)
            continuation.finish()
            await cleanup
        }
        catch let error
        {
            continuation.finish()
            await cleanup
            throw error
        }

        return success
    }
}

extension Unidoc.GraphStateLoop
{
    private
    func cleanup(cancelled requests:AsyncStream<UInt>) async
    {
        for await id:UInt in requests
        {
            self.cancel(id)
        }
    }

    private
    func cancel(_ id:UInt)
    {
        guard
        let subscriber:Subscriber = self.subscribers.removeValue(forKey: id)
        else
        {
            return
        }

        subscriber.continuation.resume(throwing: CancellationError.init())
    }

    private
    func cancelAfterTimeout(_ id:UInt) async throws
    {
        try await Task.sleep(for: self.pollingInterval)
        self.cancel(id)
    }
}

extension Unidoc.GraphStateLoop
{
    private
    func id() -> UInt
    {
        defer { self.counter += 1 }
        return  self.counter
    }

    func wait(for subscription:Subscription) async throws -> SubscriberEvent
    {
        let id:UInt = self.id()

        async
        let _:Void = self.cancelAfterTimeout(id)

        return try await withTaskCancellationHandler
        {
            try await withCheckedThrowingContinuation
            {
                (continuation:CheckedContinuation<SubscriberEvent, any Error>) in

                self.subscribers[id] = .init(
                    subscription: subscription,
                    continuation: continuation)
            }
        }
            onCancel:
        {
            self.cancellations.yield(id)
        }
    }

    private
    func wake(for event:Mongo.ChangeEvent<Unidoc.SnapshotDelta>) throws
    {
        self.clusterTime = event.clusterTime
        switch event.change
        {
        case .replace(let document, before: _, after: let snapshot):
            let _:Unidoc.Edition = document.id
            let _:Unidoc.LinkerAction? = snapshot.action

        case .update(let document, before: _, after: _):
            let subject:Unidoc.Edition = document.id
            if  document.removedFields.contains(.action)
            {
                //  Possible successful uplink event? Could also result from a manual unlink
                //  operation.
                self.subscribers = self.subscribers.filter
                {
                    if  $1.subscription.subject == subject
                    {
                        $1.continuation.resume(returning: .actionComplete)
                        return false
                    }
                    else
                    {
                        return true
                    }
                }
            }
            else
            {
                let _:Unidoc.LinkerAction? = document.updatedFields?.action
            }

        case .insert(let snapshot):
            let _:Unidoc.Edition = snapshot.id
            let _:Unidoc.LinkerAction? = snapshot.action

        case .delete(let deleted):
            let _:Unidoc.Edition = deleted.id

        case ._unimplemented:
            return
        }
    }
}
extension Unidoc.GraphStateLoop
{
    private nonisolated
    func watch(db:Unidoc.Database) async throws
    {
        var resume:BSON.Timestamp? = nil
        while true
        {
            async
            let cooldown:Void = await Task.sleep(for: .seconds(5))

            do
            {
                let session:Mongo.Session = try await .init(from: db.sessions)
                try await session.observe(collection: db.snapshots, since: &resume)
                {
                    try await self.wake(for: $0)
                }
            }
            catch let error
            {
                print(error)
            }

            try await cooldown
        }
    }
}
