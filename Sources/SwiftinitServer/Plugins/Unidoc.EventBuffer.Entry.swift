import UnixTime

extension Unidoc.EventBuffer
{
    struct Entry
    {
        let pushed:UnixInstant
        let event:Event

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
    func time(now:UnixInstant) -> Unidoc.EventTime?
    {
        self.pushed.timestamp.map
        {
            .init(components: $0.components, dynamicAge: .init(truncating: now - self.pushed))
        }
    }
}
