import UnidocProfiling

extension Unidoc.ServerMetrics
{
    @frozen public
    enum Origin:Hashable, Comparable, Sendable
    {
        case googlebot
        case googlebotVerified
        case bingbot
        case bingbotVerified
        case baiduspider
        case yandexbot
        case search
        case discoursebot
        case barbiebot
        case barbie
        case bratz
        case ahrefsbot
        case facebookexternalhit
        case script
        case cloudfront
        case github
        case githubVerified
    }
}
extension Unidoc.ServerMetrics.Origin
{
    static
    func of(_ request:Unidoc.IncomingRequest) -> Self
    {
        if  case .api = request.authorization
        {
            return .barbiebot
        }

        switch request.origin.ip.owner
        {
        case .github:                   return .githubVerified
        case .bingbot:                  return .bingbotVerified
        case .googlebot:                return .googlebotVerified
        default:                        break
        }

        guard
        let guess:Unidoc.ClientGuess = request.origin.guess
        else
        {
            return .script
        }

        switch guess
        {
        case .barbie:                   return .barbie
        case .bratz:                    return .bratz
        case .robot(let robot):
            switch robot
            {
            case .anonymous:            return .script
            case .ahrefsbot:            return .ahrefsbot
            case .amazonbot:            return .script
            case .baiduspider:          return .baiduspider
            case .bingbot:              return .bingbot
            case .cloudfront:           return .cloudfront
            case .bytespider:           return .script
            case .discoursebot:         return .discoursebot
            case .duckduckbot:          return .search
            case .google:               return .googlebot
            case .googlebot:            return .googlebot
            case .quant:                return .search
            case .naver:                return .search
            case .petal:                return .search
            case .seznam:               return .search
            case .yandexbot:            return .yandexbot
            case .unknown:              return .script
            case .other:                return .script
            case .tool:                 return .script
            case .facebookexternalhit:  return .facebookexternalhit
            }
        }
    }

    var crosstab:Unidoc.ServerMetrics.Crosstab
    {
        switch self
        {
        case .barbiebot:            return .barbiebot
        case .barbie:               return .barbie
        case .bratz:                return .bratz
        case .cloudfront:           return .cloudfront
        case .github:               return .github
        case .githubVerified:       return .github
        case .googlebot:            return .googlebot
        case .googlebotVerified:    return .googlebot
        case .bingbot:              return .bingbot
        case .bingbotVerified:      return .bingbot
        case .baiduspider:          return .search
        case .yandexbot:            return .search
        case .search:               return .search
        case .ahrefsbot:            return .script
        case .facebookexternalhit:  return .script
        case .script:               return .script
        case .discoursebot:         return .script
        }
    }
}
extension Unidoc.ServerMetrics.Origin:Identifiable
{
    @inlinable public
    var id:String
    {
        switch self
        {
        case .ahrefsbot:            return "origin-ahrefsbot"
        case .barbiebot:            return "origin-barbiebot"
        case .barbie:               return "origin-barbie"
        case .baiduspider:          return "origin-baiduspider"
        case .bingbot:              return "origin-bingbot"
        case .bingbotVerified:      return "origin-bingbot verified"
        case .bratz:                return "origin-bratz"
        case .cloudfront:           return "origin-cloudfront"
        case .discoursebot:         return "origin-discoursebot"
        case .facebookexternalhit:  return "origin-facebookexternalhit"
        case .github:               return "origin-github"
        case .githubVerified:       return "origin-github verified"
        case .googlebot:            return "origin-googlebot"
        case .googlebotVerified:    return "origin-googlebot verified"
        case .script:               return "origin-script"
        case .search:               return "origin-search"
        case .yandexbot:            return "origin-yandexbot"
        }
    }
}
extension Unidoc.ServerMetrics.Origin:PieSectorKey
{
    public
    var name:String
    {
        switch self
        {
        case .barbiebot:            return "Barbiebots"
        case .barbie:               return "Barbies"
        case .bratz:                return "Bratz"
        case .cloudfront:           return "Cloudfront"
        case .github:               return "GitHub"
        case .githubVerified:       return "GitHub (verified)"
        case .googlebot:            return "Googlebot"
        case .googlebotVerified:    return "Googlebot (verified)"
        case .bingbot:              return "Bingbot"
        case .bingbotVerified:      return "Bingbot (verified)"
        case .baiduspider:          return "Baiduspider"
        case .yandexbot:            return "Yandexbot"
        case .search:               return "Other search engines"
        case .ahrefsbot:            return "Ahrefsbot"
        case .discoursebot:         return "Discoursebot"
        case .facebookexternalhit:  return "Facebook externalhit"
        case .script:               return "Research scripts"
        }
    }
}
