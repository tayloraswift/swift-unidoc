import UnixCalendar
import UnixTime

extension Unidoc.EventBuffer
{
    @frozen @usableFromInline
    struct Entry
    {
        @usableFromInline
        let pushed:UnixAttosecond
        @usableFromInline
        let event:Event

        @inlinable
        init(pushed:UnixAttosecond, event:Event)
        {
            self.pushed = pushed
            self.event = event
        }
    }
}
extension Unidoc.EventBuffer.Entry:Sendable where Event:Sendable
{
}
extension Unidoc.EventBuffer.Entry
{
    @inlinable
    func time(now:UnixAttosecond) -> Unidoc.EventTime?
    {
        self.pushed.timestamp.map
        {
            .init(components: $0.components, dynamicAge: .init(now - self.pushed))
        }
    }
}
