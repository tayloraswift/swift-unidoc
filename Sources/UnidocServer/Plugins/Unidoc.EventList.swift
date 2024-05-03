import DequeModule
import HTML
import UnixTime

extension Unidoc
{
    @frozen public
    struct EventList<Event>
    {
        @usableFromInline
        let items:[EventBuffer<Event>.Entry]
        @usableFromInline
        let now:UnixInstant

        @inlinable
        init(items:[EventBuffer<Event>.Entry], now:UnixInstant)
        {
            self.items = items
            self.now = now
        }
    }
}
extension Unidoc.EventList:Sendable where Event:Sendable
{
}
extension Unidoc.EventList
{
    @inlinable public
    init(from buffer:borrowing Unidoc.EventBuffer<Event>, now:UnixInstant = .now())
    {
        //  This will be sent concurrently, so it will almost certainly
        //  end up being copied anyway.
        self.init(items: [_].init(buffer.entries.reversed()), now: now)
    }
}
extension Unidoc.EventList:HTML.OutputStreamable where Event:HTML.OutputStreamable
{
    @inlinable public static
    func += (ol:inout HTML.ContentEncoder, self:Self)
    {
        for entry:Unidoc.EventBuffer<Event>.Entry in self.items
        {
            ol[.li]
            {
                $0[.div, .p] = entry.time(now: self.now)
                $0[.div] = entry.event
            }
        }
    }
}
