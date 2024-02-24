import HTTP

extension ServerProfile
{
    @frozen public
    struct ByClient
    {
        public
        var verifiedGooglebot:Int
        public
        var verifiedBingbot:Int
        public
        var likelyBaiduspider:Int
        public
        var likelyYandexbot:Int
        public
        var likelyMinorSearchEngine:Int
        public
        var likelyAhrefsbot:Int
        public
        var likelyDiscoursebot:Int
        public
        var otherRobot:Int
        public
        var tooling:Int
        public
        var barbie:Int
        public
        var bratz:Int

        @inlinable public
        init(
            verifiedGooglebot:Int = 0,
            verifiedBingbot:Int = 0,
            likelyBaiduspider:Int = 0,
            likelyYandexbot:Int = 0,
            likelyMinorSearchEngine:Int = 0,
            likelyAhrefsbot:Int = 0,
            likelyDiscoursebot:Int = 0,
            otherRobot:Int = 0,
            tooling:Int = 0,
            barbie:Int = 0,
            bratz:Int = 0)
        {
            self.verifiedGooglebot = verifiedGooglebot
            self.verifiedBingbot = verifiedBingbot
            self.likelyBaiduspider = likelyBaiduspider
            self.likelyYandexbot = likelyYandexbot
            self.likelyMinorSearchEngine = likelyMinorSearchEngine
            self.likelyAhrefsbot = likelyAhrefsbot
            self.likelyDiscoursebot = likelyDiscoursebot
            self.otherRobot = otherRobot
            self.tooling = tooling
            self.barbie = barbie
            self.bratz = bratz
        }
    }
}
extension ServerProfile.ByClient:ExpressibleByDictionaryLiteral
{
    @inlinable public
    init(dictionaryLiteral elements:(Never, Int)...)
    {
        self.init(verifiedGooglebot: 0)
    }
}
extension ServerProfile.ByClient
{
    /// The total count.
    @inlinable public
    var total:Int
    {
        self.verifiedGooglebot
            + self.verifiedBingbot
            + self.likelyBaiduspider
            + self.likelyYandexbot
            + self.likelyMinorSearchEngine
            + self.likelyAhrefsbot
            + self.likelyDiscoursebot
            + self.otherRobot
            + self.tooling
            + self.barbie
            + self.bratz
    }
}
extension ServerProfile.ByClient:PieValues
{
    @inlinable public
    var sectors:KeyValuePairs<SectorKey, Int>
    {
        [
            .verifiedGooglebot:            self.verifiedGooglebot,
            .verifiedBingbot:              self.verifiedBingbot,
            .likelyBaiduspider:            self.likelyBaiduspider,
            .likelyYandexbot:              self.likelyYandexbot,
            .likelyMinorSearchEngine:      self.likelyMinorSearchEngine,
            .likelyDiscoursebot:           self.likelyDiscoursebot,
            .barbie:                       self.barbie,
            .bratz:                        self.bratz,
            .likelyAhrefsbot:              self.likelyAhrefsbot,
            .otherRobot:                   self.otherRobot,
            .tooling:                      self.tooling,
        ]
    }
}
