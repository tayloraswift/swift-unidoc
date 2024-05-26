extension Unidoc.ServerMetrics
{
    @frozen @usableFromInline
    enum Crosstab:Equatable, Hashable, Comparable, Sendable
    {
        case barbie
        case barbiebot
        case bratz
        case googlebot
        case bingbot
        case search
        case cloudfront
        case github
        case script
    }
}
extension Unidoc.ServerMetrics.Crosstab
{
    var name:String
    {
        switch self
        {
        case .barbie:       return "Barbies"
        case .barbiebot:    return "Barbiebots"
        case .bratz:        return "Bratz"
        case .googlebot:    return "Googlebot"
        case .bingbot:      return "Bingbot"
        case .search:       return "Other search engines"
        case .cloudfront:   return "Cloudfront"
        case .github:       return "GitHub"
        case .script:       return "Scripts"
        }
    }
}
