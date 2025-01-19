import Testing
@_spi(testable) import UA

@Suite
struct Parsing
{
    @Test
    static func iPhoneSafari() throws
    {
        let parsed:UA = try #require(.init("""
            Mozilla/5.0 (iPhone; CPU iPhone OS 17_1_2 like Mac OS X) \
            AppleWebKit/605.1.15 (KHTML, like Gecko) \
            Version/17.1.2 Mobile/15E148 Safari/604.1
            """))
        #expect(parsed == [
                .single("Mozilla", 5, "0"),
                .group("iPhone", "CPU iPhone OS 17_1_2 like Mac OS X"),
                .single("AppleWebKit", 605, "1.15"),
                .group("KHTML, like Gecko"),
                .single("Version", 17, "1.2"),
                .single("Mobile", .nominal("15E148")),
                .single("Safari", 604, "1"),
            ])
    }
    @Test
    static func macSafariWithPrivacyGuard() throws
    {
        let parsed:UA = try #require(.init("""
            Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) \
            AppleWebKit/605.1.15 (KHTML, like Gecko) \
            Version/14.0 Safari/605.1.15
            """))
        #expect(parsed == [
                .single("Mozilla", 5, "0"),
                .group("Macintosh", "Intel Mac OS X 10_15_7"),
                .single("AppleWebKit", 605, "1.15"),
                .group("KHTML, like Gecko"),
                .single("Version", 14, "0"),
                .single("Safari", 605, "1.15"),
            ])
    }
    @Test
    static func Bingbot() throws
    {
        let parsed:UA = try #require(.init("""
            Mozilla/5.0 AppleWebKit/537.36 \
            (KHTML, like Gecko; compatible; bingbot/2.0; \
            +http://www.bing.com/bingbot.htm) \
            Chrome/103.0.5060.134 Safari/537.36
            """))
        #expect(parsed == [
                .single("Mozilla", 5, "0"),
                .single("AppleWebKit", 537, "36"),

                .group(
                    "KHTML, like Gecko",
                    "compatible",
                    "bingbot/2.0",
                    "+http://www.bing.com/bingbot.htm"),

                .single("Chrome", 103, "0.5060.134"),
                .single("Safari", 537, "36"),
            ])
    }
    @Test
    static func Slurpbot() throws
    {
        let parsed:UA = try #require(.init("""
            Mozilla/5.0 \
            (compatible; Yahoo! Slurp; http://help.yahoo.com/help/us/ysearch/slurp)
            """))
        #expect(parsed == [
                .single("Mozilla", 5, "0"),
                .group(
                    "compatible",
                    "Yahoo! Slurp",
                    "http://help.yahoo.com/help/us/ysearch/slurp"),
            ])
    }
    @Test
    static func Edge() throws
    {
        let parsed:UA = try #require(.init("""
            Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 \
            (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36 Edg/116.0.1938.76
            """))
        #expect(parsed == [
                .single("Mozilla", 5, "0"),
                .group("Windows NT 10.0", "Win64", "x64"),
                .single("AppleWebKit", 537, "36"),
                .group("KHTML, like Gecko"),
                .single("Chrome", 116, "0.0.0"),
                .single("Safari", 537, "36"),
                .single("Edg", 116, "0.1938.76"),
            ])
    }
    @Test
    static func Censys() throws
    {
        let parsed:UA = try #require(.init("""
            Mozilla/5.0 (compatible; CensysInspect/1.1; +https://about.censys.io/)
            """))
        #expect(parsed == [
                .single("Mozilla", 5, "0"),
                .group("compatible", "CensysInspect/1.1", "+https://about.censys.io/"),
            ])
    }
    @Test
    static func TikTok() throws
    {
        let parsed:UA = try #require(.init("""
            Mozilla/5.0 (Linux; Android 5.0) AppleWebKit/537.36 (KHTML, like Gecko) \
            Mobile Safari/537.36 (compatible; Bytespider; spider-feedback@bytedance.com)
            """))
        #expect(parsed == [
                .single("Mozilla", 5, "0"),
                .group("Linux", "Android 5.0"),
                .single("AppleWebKit", 537, "36"),
                .group("KHTML, like Gecko"),
                .single("Mobile"),
                .single("Safari", 537, "36"),
                .group(
                    "compatible",
                    "Bytespider",
                    "spider-feedback@bytedance.com"),
            ])
    }
    @Test
    static func Semrush() throws
    {
        let parsed:UA = try #require(.init("""
            Mozilla/5.0 (compatible; SemrushBot/7~bl; +http://www.semrush.com/bot.html)
            """))
        #expect(parsed == [
                .single("Mozilla", 5, "0"),
                .group(
                    "compatible",
                    "SemrushBot/7~bl",
                    "+http://www.semrush.com/bot.html"),
            ])
    }
    @Test
    static func PixelImposter() throws
    {
        let parsed:UA = try #require(.init("""
            Mozilla/5.0 (Linux; Android 8.0; Pixel 2 Build/OPD3.170816.012) \
            AppleWebKit/537.36 (KHTML, like Gecko) \
            Chrome/47.0.1610.1769 Mobile Safari/537.36
            """))
        #expect(parsed == [
                .single("Mozilla", 5, "0"),
                .group("Linux", "Android 8.0", "Pixel 2 Build/OPD3.170816.012"),
                .single("AppleWebKit", 537, "36"),
                .group("KHTML, like Gecko"),
                .single("Chrome", 47, "0.1610.1769"),
                .single("Mobile"),
                .single("Safari", 537, "36"),
            ])
    }
    @Test
    static func iPhoneImposter() throws
    {
        let parsed:UA = try #require(.init("""
            Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/537.36 \
            (KHTML, like Gecko) Chrome/53.0.2012.1059 Mobile Safari/537.36
            """))
        #expect(parsed == [
                .single("Mozilla", 5, "0"),
                .group("iPhone", "CPU iPhone OS 11_0 like Mac OS X"),
                .single("AppleWebKit", 537, "36"),
                .group("KHTML, like Gecko"),
                .single("Chrome", 53, "0.2012.1059"),
                .single("Mobile"),
                .single("Safari", 537, "36"),
            ])
    }
    @Test
    static func WindowsImposter() throws
    {
        let parsed:UA = try #require(.init("""
            Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 \
            (KHTML, like Gecko) Chrome/76.0.2822.46 Safari/537.36
            """))
        #expect(parsed == [
                .single("Mozilla", 5, "0"),
                .group("Windows NT 6.3", "Win64", "x64"),
                .single("AppleWebKit", 537, "36"),
                .group("KHTML, like Gecko"),
                .single("Chrome", 76, "0.2822.46"),
                .single("Safari", 537, "36"),
            ])
    }
}
