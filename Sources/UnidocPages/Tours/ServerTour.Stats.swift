extension ServerTour
{
    @frozen public
    struct Stats
    {
        public
        var responses:ByStatus
        public
        var requests:ByType
        public
        var bytes:ByType

        @inlinable public
        init(
            responses:ByStatus = [:],
            requests:ByType = [:],
            bytes:ByType = [:])
        {
            self.responses = responses
            self.requests = requests
            self.bytes = bytes
        }
    }
}
