import BSON
import HTTPServer
import MongoDB
import Symbols

extension Unidoc
{
    public final
    actor BuildCoordinator
    {
        private nonisolated
        let eventQueue:AsyncStream<Event>.Continuation
        private nonisolated
        let channel:Symbol.Triple

        private
        var subscriptionCounter:UInt
        private
        var subscriptions:[UInt: Subscription]
        private
        var notifications:Notification?

        private
        init(eventQueue:AsyncStream<Event>.Continuation, channel:Symbol.Triple)
        {
            self.eventQueue = eventQueue
            self.channel = channel

            self.subscriptionCounter = 0
            self.subscriptions = [:]
            self.notifications = nil
        }
    }
}
extension Unidoc.BuildCoordinator
{
    public static
    func run<T>(registrar:any Unidoc.Registrar,
        watching db:Unidoc.Database,
        channel:Symbol.Triple,
        with body:(Unidoc.BuildCoordinator) async throws -> T) async rethrows -> T
    {
        let events:AsyncStream<Event>
        let eventQueue:AsyncStream<Event>.Continuation

        (events, eventQueue) = AsyncStream<Event>.makeStream()

        let coordinator:Self = .init(eventQueue: eventQueue, channel: channel)

        async
        let _:Void = coordinator.matchNotifications(from: db, to: events, registrar: registrar)
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
        let db:Unidoc.DB = try await db.session()

        guard
        let pending:Unidoc.PendingBuild = try await db.pendingBuilds.selectBuild(
            await: true,
            host: self.channel)
        else
        {
            throw Unidoc.BuildCoordinatorAssertionError.invalidChangeStreamElement
        }

        guard
        let clusterTime:BSON.Timestamp = db.session.preconditionTime
        else
        {
            throw Unidoc.BuildCoordinatorAssertionError.missingClusterTime
        }

        try await withCheckedThrowingContinuation
        {
            let notification:Notification = .init(appeared: clusterTime,
                request: pending.id,
                producer: $0)

            self.eventQueue.yield(.notify(notification))
        }
    }
}
extension Unidoc.BuildCoordinator
{
    private
    func matchNotifications(from db:Unidoc.Database,
        to events:AsyncStream<Event>,
        registrar:any Unidoc.Registrar) async
    {
        for await event:Event in events
        {
            switch event
            {
            case .submit(let id, let subscription):
                if  let buffered:Notification = self.notifications
                {
                    self.notifications = nil
                    self.subscriptions[id] = await buffered.match(with: subscription,
                        in: db,
                        registrar: registrar)
                }
                else
                {
                    self.subscriptions[id] = subscription
                }

            case .notify(let notification):
                if  let (id, buffered):(UInt, Subscription) = self.subscriptions.first
                {
                    self.subscriptions[id] = await notification.match(with: buffered,
                        in: db,
                        registrar: registrar)
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
        let id:UInt = self.subscriptionCounter
        self.subscriptionCounter += 1

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
