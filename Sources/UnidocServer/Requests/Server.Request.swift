import HTTP
import NIOCore
import UA
import UnidocProfiling

extension Server
{
    struct Request<Endpoint>:Sendable where Endpoint:Sendable
    {
        let endpoint:Endpoint

        let cookies:Cookies
        let profile:ServerProfile.Sample

        let promise:EventLoopPromise<ServerResponse>

        init(endpoint:Endpoint,
            cookies:Cookies,
            profile:ServerProfile.Sample,
            promise:EventLoopPromise<ServerResponse>)
        {
            self.endpoint = endpoint
            self.cookies = cookies
            self.profile = profile
            self.promise = promise
        }
    }
}
extension Server.Request
{
    var language:WritableKeyPath<ServerProfile.ByLanguage, Int>
    {
        guard
        let language:String = self.profile.language
        else
        {
            return \.none
        }

        var dominant:(subtag:Substring, quality:Double) = ("", 0.0)

        for language:Substring in language.split(separator: ",")
        {
            let language:Substring = language.drop(while: \.isWhitespace)
            let subtag:Substring = language.prefix(while: \.isLetter)

            var quality:Double = 1.0

            defer
            {
                if  quality > dominant.quality
                {
                    dominant = (subtag, quality)
                }
            }

            guard
            let semicolon:String.Index = language[subtag.endIndex...].firstIndex(of: ";")
            else
            {
                continue
            }

            let q:String.Index = language.index(after: semicolon)

            guard q < language.endIndex, language[q] == "q"
            else
            {
                continue
            }

            let equals:String.Index = language.index(after: q)

            guard equals < language.endIndex, language[equals] == "="
            else
            {
                continue
            }

            if  let value:Double = .init(language[language.index(after: equals)...])
            {
                quality = value
            }
        }

        switch dominant.subtag
        {
        case "zh":  return \.zh
        case "ko":  return \.ko
        case "ja":  return \.ja
        case "es":  return \.es
        case "pt":  return \.pt
        case "de":  return \.de
        case "en":  return \.en
        case "ar":  return \.ar
        case "hi":  return \.hi
        case "bn":  return \.bn
        case "ru":  return \.ru
        case _:     return \.other
        }
    }

    var agent:WritableKeyPath<ServerProfile.ByAgent, Int>
    {
        guard
        let agent:String = self.profile.agent
        else
        {
            return \.likelyTool
        }

        //  FIXME: This is a terrible way to detect search engines. Reputable search engines
        //  will publish their IP addresses, and we periodically poll them and match them
        //  by IP address instead.
        do
        {
            let string:String = agent.lowercased()

            //  Smaller search engines often include the names of larger search engines
            //  in their user agent strings.
            if      string.contains("duckduckgo")
                ||  string.contains("naver")
                ||  string.contains("petal")
                ||  string.contains("quant")
                ||  string.contains("seekport")
                ||  string.contains("seznam")
            {
                return \.likelyMinorSearchEngine
            }
            if      string.contains("bing")
                ||  string.contains("slurp")
                ||  string.contains("yandex")
                ||  string.contains("baidu")
            {
                return \.likelyMajorSearchEngine
            }
            if      string.contains("google")
            {
                return \.likelyGooglebot
            }
        }

        guard
        let agent:UA = .init(agent)
        else
        {
            return \.likelyTool
        }

        //  Didn’t send a language: definitely a bot.
        if  case nil = self.profile.language
        {
            return \.likelyRobot
        }

        /// Base suspicion level.
        var suspicion:Int = 100

        //  Sent a referrer: might be a Barbie.
        if  case _? = self.profile.referer
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

            case .single(let string, _):
                let string:String = string.lowercased()
                //  If they say they’re a bot, they’re a bot.
                if      string.contains("bot")
                    ||  string.contains("crawler")
                    ||  string.contains("spider")
                {
                    return \.likelyRobot
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

                        if      url.contains("ahrefs")
                            ||  url.contains("censys")
                            ||  url.contains("semrush")
                        {
                            return \.likelyRobot
                        }
                    }
                    //  Who is still using iOS 11?
                    else if clause == "CPU iPhone OS 11_0 like Mac OS X"
                    {
                        suspicion += 100
                    }
                    else
                    {
                        //  If they say they’re a bot, they’re a bot.
                        let string:String = clause.lowercased()

                        if      string.contains("bot")
                            ||  string.contains("crawler")
                            ||  string.contains("spider")
                        {
                            return \.likelyRobot
                        }
                    }
                }
            }
        }


        switch suspicion
        {
        case Int.min ..<  0:    return \.likelyBarbie
        case 0       ... 10:    return \.likelyBratz
        case _:                 return \.likelyRobot
        }
    }
}
