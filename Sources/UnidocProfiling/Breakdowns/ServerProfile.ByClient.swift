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
        var scanner:Int
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
            scanner:Int = 0,
            tooling:Int = 0,
            barbie:Int = 0,
            bratz:Int = 0)
        {
            self.verifiedGooglebot = verifiedGooglebot
            self.verifiedBingbot = verifiedBingbot
            self.likelyBaiduspider = likelyBaiduspider
            self.likelyYandexbot = likelyYandexbot
            self.likelyMinorSearchEngine = likelyMinorSearchEngine
            self.scanner = scanner
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
        return self.verifiedGooglebot
            + self.verifiedBingbot
            + self.likelyBaiduspider
            + self.likelyYandexbot
            + self.likelyMinorSearchEngine
            + self.scanner
            + self.tooling
            + self.barbie
            + self.bratz
    }
}
extension ServerProfile.ByClient
{
    func chart(stratum:String) -> Pie<Stat>
    {
        var chart:Pie<Stat> = []

        for (value, name, style):(Int, String, String) in
        [
            (
                self.verifiedGooglebot,
                "Verified Googlebots",
                "googlebot"
            ),
            (
                self.verifiedBingbot,
                "Verified Bingbots",
                "bingbot"
            ),
            (
                self.likelyBaiduspider,
                "Possible Baiduspiders",
                "baiduspider"
            ),
            (
                self.likelyYandexbot,
                "Possible Yandexbots",
                "yandexbot"
            ),
            (
                self.likelyMinorSearchEngine,
                "Possible Minor Search Engines",
                "minor-search-engine"
            ),
            (
                self.barbie,
                "Barbies",
                "barbie"
            ),
            (
                self.bratz,
                "Bratz",
                "bratz"
            ),
            (
                self.scanner,
                "Research Bots",
                "scanner"
            ),
            (
                self.tooling,
                "Tooling",
                "tooling"
            ),
        ]
        {
            if  value > 0
            {
                chart.append(.init(name,
                    stratum: stratum,
                    value: value,
                    class: "client \(style)"))
            }
        }

        return chart
    }
}
