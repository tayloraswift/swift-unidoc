import HTTP
import IP
import UA
import UnidocProfiling

extension Server
{
    enum ClientAnnotation:Equatable, Hashable, Sendable
    {
        case barbie(HTTP.AcceptLanguage)
        case bratz
        case robot(Robot)
    }
}
extension Server.ClientAnnotation
{
    var field:WritableKeyPath<ServerProfile.ByClient, Int>
    {
        switch self
        {
        case .barbie:                   \.barbie
        case .bratz:                    \.bratz
        case .robot(.ahrefsbot):        \.likelyAhrefsbot
        case .robot(.amazonbot):        \.likelyMinorSearchEngine
        case .robot(.baiduspider):      \.likelyBaiduspider
        case .robot(.bingbot):          \.verifiedBingbot
        case .robot(.cloudfront):       \.tooling
        case .robot(.duckduckbot):      \.likelyMinorSearchEngine
        case .robot(.google):           \.otherRobot
        case .robot(.googlebot):        \.verifiedGooglebot
        case .robot(.quant):            \.likelyMinorSearchEngine
        case .robot(.naver):            \.likelyMinorSearchEngine
        case .robot(.petal):            \.likelyMinorSearchEngine
        case .robot(.seznam):           \.likelyMinorSearchEngine
        case .robot(.yandexbot):        \.likelyYandexbot
        case .robot(.unknown):          \.otherRobot
        case .robot(.other):            \.otherRobot
        case .robot(.tool):             \.tooling
        }
    }
}
extension Server.ClientAnnotation
{
    static
    func guess(service:IP.Service?, headers:HTTP.ProfileHeaders) -> Self
    {
        switch service
        {
        case .googlebot?:   return .robot(.googlebot)
        case .bingbot?:     return .robot(.bingbot)
        case _:             break
        }

        guard
        let agent:String = headers.userAgent,
        let agent:UA = .init(agent)
        else
        {
            return .robot(.tool)
        }

        /// Base suspicion level.
        var suspicion:Int = 100

        for component:UA.Component in agent.components
        {
            switch component
            {
            case .single(let text, _):
                if  let match:Robot = .match(in: text.lowercased())
                {
                    return .robot(match)
                }

            case .group(let clauses):
                //  We would rather discriminate by URL, and most robots include their URL
                //  at the end of a clause group.
                for clause:String in clauses.reversed()
                {
                    guard
                    let first:String.Index = clause.indices.first
                    else
                    {
                        continue
                    }

                    if  case "+" = clause[first]
                    {
                        let url:Substring = clause[clause.index(after: first)...]

                        if      url.contains("yandex")
                        {
                            return .robot(.yandexbot)
                        }
                        else if url.contains("baidu")
                        {
                            return .robot(.baiduspider)
                        }
                        else if url.contains("ahrefs")
                        {
                            return .robot(.ahrefsbot)
                        }

                        if      url.contains("censys")
                            ||  url.contains("semrush")
                        {
                            return .robot(.other)
                        }
                    }
                    else if
                        let match:Robot = .match(in: clause.lowercased())
                    {
                        return .robot(match)
                    }
                    //  Who is still using iOS 11?
                    else if clause == "CPU iPhone OS 11_0 like Mac OS X"
                    {
                        suspicion += 100
                    }
                }
            }
        }

        guard
        let language:String = headers.acceptLanguage,
        let language:HTTP.AcceptLanguage = .init(language)
        else
        {
            //  Didn’t send a language: definitely a bot.
            return .robot(.other)
        }

        //  Sent a referrer: might be a Barbie.
        if  case _? = headers.referer
        {
            suspicion -= 1
        }

        for component:UA.Component in agent.components
        {
            switch component
            {
            case .single("Mozilla", let version?):
                //  Includes Mozilla/5.0: is at least pretending to be a browser.
                if  version.major == 5
                {
                    suspicion -= 100
                }

            case .single("AppleWebKit", let version?):
                //  Modern WebKit version: might be a Barbie.
                if  version.major >= 604
                {
                    suspicion -= 1
                }

            case .single("Firefox", let version?):
                //  Modern Firefox version: might be a Barbie.
                if  version.major >= 115
                {
                    suspicion -= 1
                }

            case .single("CriOS", let version?):
                //  Modern Chrome version: might be a Barbie.
                if  version.major >= 109
                {
                    suspicion -= 1
                }

            case .single("Chrome", let version?):
                //  Modern Chrome version: might be a Barbie.
                if  version.major >= 109
                {
                    suspicion -= 1
                }
                //  Very old Chrome version: probably a bot.
                if  version.major < 90
                {
                    suspicion += 10
                }

            case .single(_, _):
                continue

            case .group(_):
                continue
            }
        }


        switch suspicion
        {
        case Int.min ..<  0:    return .barbie(language)
        case 0       ... 10:    return .bratz
        case _:                 return .robot(.other)
        }
    }
}
