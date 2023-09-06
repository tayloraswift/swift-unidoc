extension Site.Admin
{
    @frozen public
    struct Tour
    {
        public
        var transferred:Int
        public
        var requests:Int
        public
        let started:ContinuousClock.Instant

        @inlinable public
        init(started:ContinuousClock.Instant = .now)
        {
            self.transferred = 0
            self.requests = 0
            self.started = started
        }
    }
}
