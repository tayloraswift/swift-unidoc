import DequeModule
import HTML
import UnixTime

extension Unidoc
{
    /// A formatting abstraction that renders an ``EventBuffer`` as a sequence of `li` elements
    /// with relative timestamps.
    ///
    /// `EventList`’s only purpose is to render HTML. Therefore, it requires `Event` to be
    /// ``HTML.OutputStreamable``. You should not store `EventList`s for a long period of time,
    /// because they contain a current time that will become stale if not immediately rendered.
    @frozen public
    struct EventList<Event> where Event:HTML.OutputStreamable
    {
        @usableFromInline
        let entries:Deque<EventBuffer<Event>.Entry>
        @usableFromInline
        let now:UnixAttosecond

        @inlinable
        init(entries:Deque<EventBuffer<Event>.Entry>, now:UnixAttosecond)
        {
            self.entries = entries
            self.now = now
        }
    }
}
extension Unidoc.EventList:HTML.OutputStreamable
{
    @inlinable public static
    func += (ol:inout HTML.ContentEncoder, self:Self)
    {
        for entry:Unidoc.EventBuffer<Event>.Entry in self.entries.reversed()
        {
            ol[.li]
            {
                $0[.div, .p] = entry.time(now: self.now)
                $0[.div] = entry.event
            }
        }
    }
}
