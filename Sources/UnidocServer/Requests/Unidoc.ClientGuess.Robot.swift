extension Unidoc.ClientGuess
{
    @frozen public
    enum Robot:Equatable, Hashable, Sendable
    {
        /// A bot that sent no User-Agent header at all.
        case anonymous

        case ahrefsbot

        case amazonbot

        /// Crawler belonging to Baidu, a Chinese search engine.
        case baiduspider
        /// Crawler belonging to Bing, an American search engine.
        case bingbot
        /// Mozilla/5.0 (Linux; Android 5.0)
        /// AppleWebKit/537.36 (KHTML, like Gecko) Mobile Safari/537.36
        /// (compatible; Bytespider; spider-feedback@bytedance.com)
        case bytespider

        /// Amazon CloudFront.
        case cloudfront

        case discoursebot

        /// Crawler belonging to DuckDuckGo, an American search engine. Only the favicon
        /// bot is active today.
        case duckduckbot

        case facebookexternalhit

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

        /// Some other bot.
        case other

        case tool
    }
}
