extension ServerProfile
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
        var likelyRobot:Int

        @inlinable public
        init(
            likelyGooglebot:Int = 0,
            likelyMajorSearchEngine:Int = 0,
            likelyMinorSearchEngine:Int = 0,
            likelyBrowser:Int = 0,
            likelyTool:Int = 0,
            likelyRobot:Int = 0)
        {
            self.likelyGooglebot = likelyGooglebot
            self.likelyMajorSearchEngine = likelyMajorSearchEngine
            self.likelyMinorSearchEngine = likelyMinorSearchEngine
            self.likelyBrowser = likelyBrowser
            self.likelyTool = likelyTool
            self.likelyRobot = likelyRobot
        }
    }
}
extension ServerProfile.ByAgent:ExpressibleByDictionaryLiteral
{
    @inlinable public
    init(dictionaryLiteral elements:(Never, Int)...)
    {
        self.init(likelyGooglebot: 0)
    }
}
extension ServerProfile.ByAgent
{
    /// The total count.
    @inlinable public
    var total:Int
    {
        return self.likelyGooglebot
            + self.likelyMajorSearchEngine
            + self.likelyMinorSearchEngine
            + self.likelyBrowser
            + self.likelyTool
            + self.likelyRobot
    }
}
extension ServerProfile.ByAgent
{
    func chart(stratum:String) -> Pie<Stat>
    {
        var chart:Pie<Stat> = []

        for (value, name, style):(Int, String, String) in
        [
            (
                self.likelyGooglebot,
                "Googlebot",
                "googlebot"
            ),
            (
                self.likelyMajorSearchEngine,
                "Major Search Engines",
                "major-search-engine"
            ),
            (
                self.likelyMinorSearchEngine,
                "Minor Search Engines",
                "minor-search-engine"
            ),
            (
                self.likelyBrowser,
                "Barbies",
                "browser"
            ),
            (
                self.likelyTool,
                "Tools",
                "tool"
            ),
            (
                self.likelyRobot,
                "Research Bots",
                "bot"
            ),
        ]
        {
            if  value > 0
            {
                chart.append(.init(name,
                    stratum: stratum,
                    value: value,
                    class: "agent \(style)"))
            }
        }

        return chart
    }
}
