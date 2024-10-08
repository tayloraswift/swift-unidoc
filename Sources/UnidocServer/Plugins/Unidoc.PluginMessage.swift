import UnixCalendar
import UnixTime

extension Unidoc
{
    @frozen public
    struct PluginMessage:Sendable
    {
        @usableFromInline
        let event:any PluginEvent
        @usableFromInline
        let date:UnixAttosecond

        @inlinable public
        init(event:any PluginEvent, date:UnixAttosecond)
        {
            self.event = event
            self.date = date
        }
    }
}
extension Unidoc.PluginMessage
{
    @inlinable
    func header(now:UnixAttosecond) -> DateHeader?
    {
        self.date.timestamp.map
        {
            .init(components: $0.components, dynamicAge: .init(now - self.date))
        }
    }
}
