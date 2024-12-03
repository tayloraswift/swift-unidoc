import UnixCalendar
import UnixTime

extension Unidoc.ServerLog
{
    @frozen public
    struct Message:Sendable
    {
        @usableFromInline
        let event:any Unidoc.ServerEvent
        @usableFromInline
        let date:UnixAttosecond

        @inlinable public
        init(event:any Unidoc.ServerEvent, date:UnixAttosecond)
        {
            self.event = event
            self.date = date
        }
    }
}
extension Unidoc.ServerLog.Message
{
    @inlinable
    func header(now:UnixAttosecond) -> Unidoc.ServerLog.MessageHeader?
    {
        self.date.timestamp.map
        {
            .init(components: $0.components, dynamicAge: .init(now - self.date))
        }
    }
}
