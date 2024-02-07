import UnixTime

extension Swiftinit.EventBuffer
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
extension Swiftinit.EventBuffer.Entry:Sendable where Event:Sendable
{
}
extension Swiftinit.EventBuffer.Entry
{
    func time(now:UnixInstant) -> Swiftinit.EventTime?
    {
        self.pushed.timestamp.map
        {
            .init(stamp: $0.components, age: .init(now - self.pushed))
        }
    }
}
