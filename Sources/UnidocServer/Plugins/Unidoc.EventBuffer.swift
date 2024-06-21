import DequeModule
import HTML
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
        init(limit:Int)
        {
            self.entries = .init(minimumCapacity: limit)
            self.limit = limit
        }
    }
}
extension Unidoc.EventBuffer:Sendable where Event:Sendable
{
}
extension Unidoc.EventBuffer:RandomAccessCollection
{
    @inlinable public
    var startIndex:Int { self.entries.startIndex }
    @inlinable public
    var endIndex:Int { self.entries.endIndex }

    @inlinable public
    subscript(index:Int) -> Event { self.entries[index].event }
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
extension Unidoc.EventBuffer where Event:HTML.OutputStreamable
{
    @inlinable public
    func list(now:UnixInstant) -> Unidoc.EventList<Event>
    {
        .init(entries: self.entries, now: now)
    }
}
