extension ServerTour
{
    @frozen public
    struct SlowestQuery:Sendable
    {
        public
        let time:Duration
        public
        let path:String

        @inlinable public
        init(time:Duration, path:String)
        {
            self.time = time
            self.path = path
        }
    }
}
