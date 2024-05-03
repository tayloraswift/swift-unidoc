import MongoDB
import UnidocServer

extension Swiftinit
{
    struct Airdrop
    {
        private
        let status:AtomicPointer<Unidoc.CollectionEventsPage<Self>>
        private
        let policy:Unidoc.Database.Policy
        private
        var buffer:Unidoc.EventBuffer<Event>

        init(updating status:AtomicPointer<Unidoc.CollectionEventsPage<Self>>,
            policy:Unidoc.Database.Policy)
        {
            self.status = status
            self.policy = policy
            self.buffer = .init(minimumCapacity: 100)
        }
    }
}
extension Swiftinit.Airdrop:Unidoc.CollectionVisitor
{
    static
    var title:String { "Airdrop" }

    mutating
    func publish(event:Event)
    {
        self.buffer.push(event: event)
        self.publish()
    }

    func publish()
    {
        self.status.replace(value: .init(list: .init(from: self.buffer)))
    }

    mutating
    func tour(in db:Unidoc.DB, with session:Mongo.Session) async throws
    {
        let period:Duration = self.policy.apiLimitInterval

        async
        let next:Void = Task.sleep(for: period)

        var affected:Int
        repeat
        {
            async
            let cooldown:Void = Task.sleep(for: .seconds(5))

            affected = try await db.users.airdrop(reset: self.policy.apiLimitPerReset,
                limit: 1000,
                with: session)

            self.publish(event: .airdropped(to: affected))

            try await cooldown
        }
        while affected > 0

        try await next
    }
}
