extension ServerTour.Stats
{
    @frozen public
    struct ByStatus
    {
        public
        var ok:Int
        public
        var notModified:Int
        public
        var redirectedPermanently:Int
        public
        var redirectedTemporarily:Int
        public
        var notFound:Int
        public
        var errored:Int
        public
        var unauthorized:Int

        @inlinable public
        init(ok:Int = 0,
            notModified:Int = 0,
            redirectedPermanently:Int = 0,
            redirectedTemporarily:Int = 0,
            notFound:Int = 0,
            errored:Int = 0,
            unauthorized:Int = 0)
        {
            self.ok = ok
            self.notModified = notModified
            self.redirectedPermanently = redirectedPermanently
            self.redirectedTemporarily = redirectedTemporarily
            self.notFound = notFound
            self.errored = errored
            self.unauthorized = unauthorized
        }
    }
}
extension ServerTour.Stats.ByStatus:ExpressibleByDictionaryLiteral
{
    @inlinable public
    init(dictionaryLiteral elements:(Never, Int)...)
    {
        self.init(ok: 0)
    }
}
