extension ServerProfile.ByClient
{
    @frozen public
    enum SectorKey
    {
        case verifiedGooglebot
        case verifiedBingbot
        case likelyBaiduspider
        case likelyYandexbot
        case likelyMinorSearchEngine
        case likelyAhrefsbot
        case otherRobot
        case tooling
        case barbie
        case bratz
    }
}
extension ServerProfile.ByClient.SectorKey:Identifiable
{
    @inlinable public
    var id:String
    {
        switch self
        {
        case .verifiedGooglebot:            "googlebot"
        case .verifiedBingbot:              "bingbot"
        case .likelyBaiduspider:            "baiduspider"
        case .likelyYandexbot:              "yandexbot"
        case .likelyMinorSearchEngine:      "minor-search-engine"
        case .likelyAhrefsbot:              "ahrefsbot"
        case .otherRobot:                   "robot"
        case .tooling:                      "tooling"
        case .barbie:                       "barbie"
        case .bratz:                        "bratz"
        }
    }
}
extension ServerProfile.ByClient.SectorKey:PieSectorKey
{
    @inlinable public
    var name:String
    {
        switch self
        {
        case .verifiedGooglebot:            "Googlebots (Verified)"
        case .verifiedBingbot:              "Bingbots (Verified)"
        case .likelyBaiduspider:            "Baiduspiders"
        case .likelyYandexbot:              "Yandexbots"
        case .likelyMinorSearchEngine:      "Minor Search Engines"
        case .likelyAhrefsbot:              "Ahrefsbots"
        case .otherRobot:                   "Other Robots"
        case .tooling:                      "Tooling"
        case .barbie:                       "Barbies"
        case .bratz:                        "Bratz"
        }
    }
}
