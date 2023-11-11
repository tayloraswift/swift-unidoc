import HTTP

extension Server.ClientAnnotation
{
    enum Robot:Equatable, Hashable, Sendable
    {
        case ahrefsbot

        case amazonbot

        /// Crawler belonging to Baidu, a Chinese search engine.
        case baiduspider
        /// Crawler belonging to Bing, an American search engine.
        case bingbot

        /// Amazon CloudFront.
        case cloudfront
        /// Crawler belonging to DuckDuckGo, an American search engine. Only the favicon
        /// bot is active today.
        case duckduckbot

        /// AdsBot, or possible Google employee.
        case google
        /// Crawler belonging to Google, an American search engine.
        case googlebot
        /// Crawler belonging to Quant, a French search engine.
        case quant
        /// Crawler belonging to Naver, a Korean search engine.
        case naver
        /// Crawler belonging to Huawei, allegedly powers a mobile Chinese search engine.
        case petal
        /// Crawler belonging to Seznam, a Czech search engine.
        case seznam
        /// Crawler belonging to Yahoo!, an American search engine; also known as Slurp.
        @available(*, unavailable, message: "defunct")
        case slurpbot
        /// Crawler belonging to Yandex, a Russian search engine.
        case yandexbot

        /// A bot whose provenance is unknown because our policylists are incomplete.
        /// Don’t use this to represent a generic research bot; use ``other`` instead.
        case unknown

        /// Some other bot.
        case other

        case tool
    }
}
extension Server.ClientAnnotation.Robot
{
    static
    func match(in string:String) -> Self?
    {
        if      string.contains("cloudfront")
        {
            return .cloudfront
        }
        if      string.contains("amazonbot")
        {
            return .amazonbot
        }
        else if string.contains("baidu")
        {
            return .baiduspider
        }
        else if string.contains("duckduck")
        {
            return .duckduckbot
        }
        else if string.contains("naver")
        {
            return .naver
        }
        else if string.contains("quant")
        {
            return .quant
        }
        else if string.contains("petal")
        {
            return .petal
        }
        else if string.contains("seznam")
        {
            return .seznam
        }
        else if string.contains("yandex")
        {
            return .yandexbot
        }
        else if string.contains("bot")
            ||  string.contains("crawler")
            ||  string.contains("spider")
        {
            return .other
        }
        else
        {
            return nil
        }
    }
}
