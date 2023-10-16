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
        var likelyBarbie:Int
        public
        var likelyBratz:Int
        public
        var likelyRobot:Int
        public
        var likelyTool:Int

        @inlinable public
        init(
            likelyGooglebot:Int = 0,
            likelyMajorSearchEngine:Int = 0,
            likelyMinorSearchEngine:Int = 0,
            likelyBarbie:Int = 0,
            likelyBratz:Int = 0,
            likelyRobot:Int = 0,
            likelyTool:Int = 0)
        {
            self.likelyGooglebot = likelyGooglebot
            self.likelyMajorSearchEngine = likelyMajorSearchEngine
            self.likelyMinorSearchEngine = likelyMinorSearchEngine
            self.likelyBarbie = likelyBarbie
            self.likelyBratz = likelyBratz
            self.likelyRobot = likelyRobot
            self.likelyTool = likelyTool
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
            + self.likelyBarbie
            + self.likelyBratz
            + self.likelyRobot
            + self.likelyTool
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
                self.likelyBarbie,
                "Barbies",
                "barbie"
            ),
            (
                self.likelyBratz,
                "Bratz",
                "bratz"
            ),
            (
                self.likelyRobot,
                "Research Bots",
                "robot"
            ),
            (
                self.likelyTool,
                "Tools",
                "tool"
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
