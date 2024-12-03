import UnixTime

extension Unidoc.Observation
{
    @frozen public
    struct ServerTriggered:Sendable
    {
        public
        let event:any Unidoc.ServerEvent
        public
        let type:Unidoc.ServerEventType
        public
        let date:UnixAttosecond

        @inlinable public
        init(event:any Unidoc.ServerEvent, type:Unidoc.ServerEventType, date:UnixAttosecond)
        {
            self.event = event
            self.type = type
            self.date = date
        }
    }
}
