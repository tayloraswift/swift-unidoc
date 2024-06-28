import BSON
import HTTPServer
import MongoDB

extension Unidoc
{
    public final
    actor BuildCoordinator
    {
        private nonisolated
        let eventQueue:AsyncStream<Event>.Continuation
        private
        var counter:UInt
        private
        var subscriptions:[UInt: Subscription]
        private
        var notifications:Notification?

        private
        init(eventQueue:AsyncStream<Event>.Continuation)
        {
            self.eventQueue = eventQueue
            self.counter = 0

            self.subscriptions = [:]
            self.notifications = nil
        }
    }
}
extension Unidoc.BuildCoordinator
{
    public static
    func run<T>(watching db:Unidoc.Database,
        with body:(Unidoc.BuildCoordinator) async throws -> T) async rethrows -> T
    {
        let events:AsyncStream<Event>
        let eventQueue:AsyncStream<Event>.Continuation

        (events, eventQueue) = AsyncStream<Event>.makeStream()

        let coordinator:Self = .init(eventQueue: eventQueue)

        async
        let _:Void = coordinator.matchNotifications(from: db, to: events)
        async
        let _:Void = coordinator.pullNotifications(from: db)

        return try await body(coordinator)
    }
}

extension Unidoc.BuildCoordinator
{
    /// Returns on task cancellation only. Retries upon all other errors after a 5 second
    /// cooldown period.
    private nonisolated
    func pullNotifications(from db:Unidoc.Database) async
    {
        while true
        {
            async
            let cooldown:Void = await Task.sleep(for: .seconds(5))

            do
            {
                try await self.pullNotification(from: db)
            }
            catch let error
            {
                Log[.error] = "Failed to pull build metadata: \(error)"
            }

            do
            {
                try await cooldown
            }
            catch
            {
                return
            }
        }
    }

    private nonisolated
    func pullNotification(from db:Unidoc.Database) async throws
    {
        let session:Mongo.Session = try await .init(from: db.sessions)

        guard
        let metadata:Unidoc.BuildMetadata = try await db.packageBuilds.selectBuild(
            await: true,
            with: session),
        let request:Unidoc.BuildRequest = metadata.request
        else
        {
            throw Unidoc.BuildCoordinatorAssertionError.invalidChangeStreamElement
        }

        guard
        let clusterTime:BSON.Timestamp = session.preconditionTime
        else
        {
            throw Unidoc.BuildCoordinatorAssertionError.missingClusterTime
        }

        try await withCheckedThrowingContinuation
        {
            let notification:Notification = .init(appeared: clusterTime,
                package: metadata.id,
                request: request,
                producer: $0)

            self.eventQueue.yield(.notify(notification))
        }
    }
}
extension Unidoc.BuildCoordinator
{
    private
    func matchNotifications(from db:Unidoc.Database, to events:AsyncStream<Event>) async
    {
        for await event:Event in events
        {
            switch event
            {
            case .submit(let id, let subscription):
                if  let buffered:Notification = self.notifications
                {
                    self.notifications = nil
                    self.subscriptions[id] = await buffered.match(with: subscription, in: db)
                }
                else
                {
                    self.subscriptions[id] = subscription
                }

            case .notify(let notification):
                if  let (id, buffered):(UInt, Subscription) = self.subscriptions.first
                {
                    self.subscriptions[id] = await notification.match(with: buffered, in: db)
                }
                else
                {
                    self.notifications = notification
                }

            case .cancel(let id):
                if  let subscription:Subscription = self.subscriptions.removeValue(forKey: id)
                {
                    subscription.cancel()
                }
            }
        }
    }
}
extension Unidoc.BuildCoordinator
{
    func match(builder:Unidoc.Account) async throws -> Unidoc.BuildLabels
    {
        let id:UInt = self.counter
        self.counter += 1

        return try await withTaskCancellationHandler
        {
            try await withCheckedThrowingContinuation
            {
                self.eventQueue.yield(.submit(id, .init(assignee: builder, consumer: $0)))
            }
        }
            onCancel:
        {
            self.eventQueue.yield(.cancel(id))
        }
    }
}
