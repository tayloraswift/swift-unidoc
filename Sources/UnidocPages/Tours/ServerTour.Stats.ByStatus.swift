extension ServerTour.Stats
{
    @frozen public
    struct ByAgent
    {
        public
        var likelySearchEngine:Int
        public
        var likelyBot:Int
        public
        var likelyBrowser:Int
        public
        var other:Int

        @inlinable public
        init(likelySearchEngine:Int = 0,
            likelyBot:Int = 0,
            likelyBrowser:Int = 0,
            other:Int = 0)
        {
            self.likelySearchEngine = likelySearchEngine
            self.likelyBot = likelyBot
            self.likelyBrowser = likelyBrowser
            self.other = other
        }
    }
}
extension ServerTour.Stats.ByAgent:ExpressibleByDictionaryLiteral
{
    @inlinable public
    init(dictionaryLiteral elements:(Never, Int)...)
    {
        self.init(likelySearchEngine: 0)
    }
}
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
        var multipleChoices:Int
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
            multipleChoices:Int = 0,
            redirectedPermanently:Int = 0,
            redirectedTemporarily:Int = 0,
            notFound:Int = 0,
            errored:Int = 0,
            unauthorized:Int = 0)
        {
            self.ok = ok
            self.notModified = notModified
            self.multipleChoices = multipleChoices
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
