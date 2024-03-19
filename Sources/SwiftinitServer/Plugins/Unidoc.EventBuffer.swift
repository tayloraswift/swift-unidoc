import DequeModule
import UnixTime

extension Unidoc
{
    struct EventBuffer<Event>
    {
        private(set)
        var entries:Deque<Entry>
        private
        let limit:Int

        init(minimumCapacity limit:Int)
        {
            self.entries = .init(minimumCapacity: limit)
            self.limit = limit
        }
    }
}
extension Unidoc.EventBuffer:Sendable where Event:Sendable
{
}
extension Unidoc.EventBuffer
{
    mutating
    func push(event:Event)
    {
        if  self.entries.count == self.limit
        {
            self.entries.removeFirst()
        }

        self.entries.append(.init(pushed: .now(), event: event))
    }
}
