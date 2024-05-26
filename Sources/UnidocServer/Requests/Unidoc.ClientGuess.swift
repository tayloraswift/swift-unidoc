import HTTP
import HTTPServer
import NIOHPACK
import NIOHTTP1
import UA
import UnidocProfiling

extension Unidoc
{
    @frozen public
    enum ClientGuess:Equatable, Hashable, Sendable
    {
        case barbie(HTTP.Locale)
        case bratz
        case robot(Robot)
    }
}
extension Unidoc.ClientGuess
{
    private static
    func from(acceptLanguage:String?,
        userAgent:String?,
        referer:String?) -> Self
    {
        guard
        let userAgent:String
        else
        {
            return .robot(.anonymous)
        }

        if  userAgent.starts(with: "Discourse Forum Onebox")
        {
            // This is *probably* the Swift Forums bot.
            return .robot(.discoursebot)
        }

        guard
        let userAgent:UA = .init(userAgent)
        else
        {
            return .robot(.tool)
        }

        /// Base suspicion level.
        var suspicion:Int = 100

        for component:UA.Component in userAgent.components
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
        let acceptLanguage:String,
        let acceptLanguage:HTTP.AcceptLanguage = .init(acceptLanguage),
        let locale:HTTP.Locale = acceptLanguage.dominant
        else
        {
            //  Didn’t send a locale: definitely a bot.
            return .robot(.other)
        }

        //  Sent a referrer: might be a Barbie.
        if  case _? = referer
        {
            suspicion -= 1
        }

        for component:UA.Component in userAgent.components
        {
            switch component
            {
            case .single("Mozilla", let version?):
                //  Includes Mozilla/5.0: is at least pretending to be a browser.
                if  version.major == 5
                {
                    suspicion -= 100
                }

            case .single("AppleWebKit", .numeric(let version, _)?):
                //  Modern WebKit version: might be a Barbie.
                if  version >= 604
                {
                    suspicion -= 1
                }

            case .single("Firefox", .numeric(let version, _)?):
                //  Modern Firefox version: might be a Barbie.
                if  version >= 115
                {
                    suspicion -= 1
                }

            case .single("CriOS", .numeric(let version, _)?):
                //  Modern Chrome version: might be a Barbie.
                if  version >= 109
                {
                    suspicion -= 1
                }

            case .single("Chrome", .numeric(let version, _)?):
                //  Modern Chrome version: might be a Barbie.
                if  version >= 109
                {
                    suspicion -= 1
                }
                //  Very old Chrome version: probably a bot.
                if  version < 90
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
        case Int.min ..<  0:    return .barbie(locale)
        case 0       ... 10:    return .bratz
        case _:                 return .robot(.other)
        }
    }
}
extension Unidoc.ClientGuess
{
    static
    func from(_ headers:HTTPHeaders) -> Self
    {
        .from(
            acceptLanguage: headers["accept-language"].last,
            userAgent: headers["user-agent"].last,
            referer: headers["referer"].last)
    }
    static
    func from(_ headers:HPACKHeaders) -> Self
    {
        .from(
            acceptLanguage: headers["accept-language"].last,
            userAgent: headers["user-agent"].last,
            referer: headers["referer"].last)
    }
}
extension Unidoc.ClientGuess
{
    var locale:HTTP.Locale?
    {
        switch self
        {
        case .barbie(let locale):   locale
        case .bratz:                nil
        case .robot(_):             nil
        }
    }
}
