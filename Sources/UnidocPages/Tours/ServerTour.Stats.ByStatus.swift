extension ServerTour.Stats
{
    @frozen public
    struct ByAgent
    {
        public
        var likelyGooglebot:Int
        public
        var likelyMajorSearchEngine:Int
        public
        var likelyMinorSearchEngine:Int
        public
        var likelyBrowser:Int
        public
        var likelyTool:Int
        public
        var likelyBot:Int

        @inlinable public
        init(
            likelyGooglebot:Int = 0,
            likelyMajorSearchEngine:Int = 0,
            likelyMinorSearchEngine:Int = 0,
            likelyBrowser:Int = 0,
            likelyTool:Int = 0,
            likelyBot:Int = 0)
        {
            self.likelyGooglebot = likelyGooglebot
            self.likelyMajorSearchEngine = likelyMajorSearchEngine
            self.likelyMinorSearchEngine = likelyMinorSearchEngine
            self.likelyBrowser = likelyBrowser
            self.likelyTool = likelyTool
            self.likelyBot = likelyBot
        }
    }
}
extension ServerTour.Stats.ByAgent:ExpressibleByDictionaryLiteral
{
    @inlinable public
    init(dictionaryLiteral elements:(Never, Int)...)
    {
        self.init(likelyGooglebot: 0)
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
