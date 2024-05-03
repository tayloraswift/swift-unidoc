import DynamicTime
import UnixTime

extension Unidoc.EventBuffer
{
    @frozen @usableFromInline
    struct Entry
    {
        @usableFromInline
        let pushed:UnixInstant
        @usableFromInline
        let event:Event

        @inlinable
        init(pushed:UnixInstant, event:Event)
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
    func time(now:UnixInstant) -> Unidoc.EventTime?
    {
        self.pushed.timestamp.map
        {
            .init(components: $0.components, dynamicAge: .init(truncating: now - self.pushed))
        }
    }
}
