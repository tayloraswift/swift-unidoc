import BSON
import HTTPServer
import MongoDB
import Symbols

extension Unidoc
{
    public final
    actor BuildCoordinator
    {
        nonisolated
        let id:Symbol.Triple

        private nonisolated
        let eventQueue:AsyncStream<Event>.Continuation
        private nonisolated
        let events:AsyncStream<Event>

        private
        var subscriptionCounter:UInt
        private
        var subscriptions:[UInt: Subscription]
        private
        var notifications:Notification?

        private
        init(id:Symbol.Triple,
            eventQueue:AsyncStream<Event>.Continuation,
            events:AsyncStream<Event>)
        {
            self.id = id
            self.eventQueue = eventQueue
            self.events = events

            self.subscriptionCounter = 0
            self.subscriptions = [:]
            self.notifications = nil
        }
    }
}
extension Unidoc.BuildCoordinator
{
    public
    init(id:Symbol.Triple)
    {
        let eventQueue:AsyncStream<Event>.Continuation
        let events:AsyncStream<Event>

        (events, eventQueue) = AsyncStream<Event>.makeStream()

        self.init(id: id, eventQueue: eventQueue, events: events)
    }

    public
    func run(registrar:any Unidoc.Registrar, watching db:Unidoc.Database) async
    {
        async
        let _:Void = self.pullNotifications(from: db)
        await self.matchNotifications(from: db, registrar: registrar)
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
            host: self.id)
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
    func matchNotifications(from db:Unidoc.Database, registrar:any Unidoc.Registrar) async
    {
        for await event:Event in self.events
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
