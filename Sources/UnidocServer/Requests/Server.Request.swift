import HTTP
import NIOCore
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
        case "es":  return \.es
        case "en":  return \.en
        case "ar":  return \.ar
        case "hi":  return \.hi
        case "bn":  return \.bn
        case "pt":  return \.pt
        case "ru":  return \.ru
        case _:     return \.other
        }
    }

    var agent:WritableKeyPath<ServerProfile.ByAgent, Int>
    {
        guard
        let string:String = self.profile.agent?.lowercased()
        else
        {
            return \.likelyTool
        }

        if      string.contains("google")
        {
            return \.likelyGooglebot
        }

        if      string.contains("bing")
            ||  string.contains("slurp")
            ||  string.contains("yandex")
            ||  string.contains("baidu")
        {
            return \.likelyMajorSearchEngine
        }
        if      string.contains("duckduckgo")
            ||  string.contains("naver")
            ||  string.contains("petal")
            ||  string.contains("quant")
            ||  string.contains("seekport")
            ||  string.contains("seznam")
        {
            return \.likelyMinorSearchEngine
        }
        if      string.contains("bot")
            ||  string.contains("crawler")
            ||  string.contains("spider")
        {
            return \.likelyRobot
        }
        if      string.contains("mozilla")
        {
            return \.likelyBrowser
        }
        else
        {
            return \.likelyTool
        }
    }
}
