extension ServerTour
{
    @frozen public
    struct Stats
    {
        public
        var agents:ByAgent
        public
        var responses:ByStatus
        public
        var requests:ByType
        public
        var bytes:ByType

        @inlinable public
        init(
            agents:ByAgent = [:],
            responses:ByStatus = [:],
            requests:ByType = [:],
            bytes:ByType = [:])
        {
            self.agents = agents
            self.responses = responses
            self.requests = requests
            self.bytes = bytes
        }
    }
}
