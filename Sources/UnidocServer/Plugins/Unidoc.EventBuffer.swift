import DequeModule
import UnixTime

extension Unidoc
{
    @frozen public
    struct EventBuffer<Event>
    {
        @usableFromInline
        var entries:Deque<Entry>
        @usableFromInline
        let limit:Int

        @inlinable public
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
    @inlinable public mutating
    func push(event:Event)
    {
        if  self.entries.count == self.limit
        {
            self.entries.removeFirst()
        }

        self.entries.append(.init(pushed: .now(), event: event))
    }
}
