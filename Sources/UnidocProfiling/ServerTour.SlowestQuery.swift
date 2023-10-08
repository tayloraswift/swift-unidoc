extension ServerTour
{
    @frozen public
    struct SlowestQuery:Sendable
    {
        public
        let duration:Duration
        public
        let uri:String

        @inlinable public
        init(duration:Duration, uri:String)
        {
            self.duration = duration
            self.uri = uri
        }
    }
}
