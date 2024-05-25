import URI

extension ServerTour
{
    @frozen public
    struct SlowestQuery:Sendable
    {
        public
        let time:Duration
        public
        let uri:URI

        @inlinable public
        init(time:Duration, uri:URI)
        {
            self.time = time
            self.uri = uri
        }
    }
}
