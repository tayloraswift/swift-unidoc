import MongoDB
import UnidocServer
import UnixTime

extension Swiftinit
{
    struct Linter
    {
        private
        let status:AtomicPointer<Unidoc.CollectionEventsPage<Self>>
        private
        var buffer:Unidoc.EventBuffer<Event>

        init(updating status:AtomicPointer<Unidoc.CollectionEventsPage<Self>>)
        {
            self.status = status
            self.buffer = .init(minimumCapacity: 100)
        }
    }
}
extension Swiftinit.Linter:Unidoc.CollectionVisitor
{
    static
    var title:String { "Linter" }

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
        async
        let period:Void = Task.sleep(for: .seconds(30))
        let cutoff:UnixInstant = .now() - .seconds(60) * 30

        self.publish(event: .lintedBuilds(try await db.packageBuilds.lintBuilds(
            startedBefore: .init(cutoff),
            with: session)))

        try await period
    }
}
