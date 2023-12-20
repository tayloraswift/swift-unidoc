import Testing

@_spi(testable)
import UA

extension Main
{
    struct Parsing
    {
    }
}

import Grammar

extension Main.Parsing:TestBattery
{
    private static
    func run(_ tests:TestGroup, parsing string:String, expected:UA)
    {
        if  let parsed:UA = tests.expect(value: .init(string))
        {
            tests.expect(parsed ==? expected)
        }
    }

    static
    func run(tests:TestGroup)
    {
        if  let tests:TestGroup = tests / "iPhoneSafari"
        {
            Self.run(tests,
                parsing: """
                Mozilla/5.0 (iPhone; CPU iPhone OS 17_1_2 like Mac OS X) \
                AppleWebKit/605.1.15 (KHTML, like Gecko) \
                Version/17.1.2 Mobile/15E148 Safari/604.1
                """,
                expected:
                [
                    .single("Mozilla", 5, "0"),
                    .group("iPhone", "CPU iPhone OS 17_1_2 like Mac OS X"),
                    .single("AppleWebKit", 605, "1.15"),
                    .group("KHTML, like Gecko"),
                    .single("Version", 17, "1.2"),
                    .single("Mobile", .nominal("15E148")),
                    .single("Safari", 604, "1"),
                ])
        }
        if  let tests:TestGroup = tests / "macSafariWithPrivacyGuard"
        {
            Self.run(tests,
                parsing: """
                Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) \
                AppleWebKit/605.1.15 (KHTML, like Gecko) \
                Version/14.0 Safari/605.1.15
                """,
                expected:
                [
                    .single("Mozilla", 5, "0"),
                    .group("Macintosh", "Intel Mac OS X 10_15_7"),
                    .single("AppleWebKit", 605, "1.15"),
                    .group("KHTML, like Gecko"),
                    .single("Version", 14, "0"),
                    .single("Safari", 605, "1.15"),
                ])
        }
        if  let tests:TestGroup = tests / "Bingbot"
        {
            Self.run(tests,
                parsing: """
                Mozilla/5.0 AppleWebKit/537.36 \
                (KHTML, like Gecko; compatible; bingbot/2.0; \
                +http://www.bing.com/bingbot.htm) \
                Chrome/103.0.5060.134 Safari/537.36
                """,
                expected:
                [
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
        if  let tests:TestGroup = tests / "Slurpbot"
        {
            Self.run(tests,
                parsing: """
                Mozilla/5.0 \
                (compatible; Yahoo! Slurp; http://help.yahoo.com/help/us/ysearch/slurp)
                """,
                expected:
                [
                    .single("Mozilla", 5, "0"),
                    .group(
                        "compatible",
                        "Yahoo! Slurp",
                        "http://help.yahoo.com/help/us/ysearch/slurp"),
                ])
        }
        if  let tests:TestGroup = tests / "Edge"
        {
            Self.run(tests,
                parsing: """
                Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 \
                (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36 Edg/116.0.1938.76
                """,
                expected:
                [
                    .single("Mozilla", 5, "0"),
                    .group("Windows NT 10.0", "Win64", "x64"),
                    .single("AppleWebKit", 537, "36"),
                    .group("KHTML, like Gecko"),
                    .single("Chrome", 116, "0.0.0"),
                    .single("Safari", 537, "36"),
                    .single("Edg", 116, "0.1938.76"),
                ])
        }
        if  let tests:TestGroup = tests / "Censys"
        {
            Self.run(tests,
                parsing: """
                Mozilla/5.0 (compatible; CensysInspect/1.1; +https://about.censys.io/)
                """,
                expected:
                [
                    .single("Mozilla", 5, "0"),
                    .group("compatible", "CensysInspect/1.1", "+https://about.censys.io/"),
                ])
        }
        if  let tests:TestGroup = tests / "TikTok"
        {
            Self.run(tests,
                parsing: """
                Mozilla/5.0 (Linux; Android 5.0) AppleWebKit/537.36 (KHTML, like Gecko) \
                Mobile Safari/537.36 (compatible; Bytespider; spider-feedback@bytedance.com)
                """,
                expected:
                [
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
        if  let tests:TestGroup = tests / "Semrush"
        {
            Self.run(tests,
                parsing: """
                Mozilla/5.0 (compatible; SemrushBot/7~bl; +http://www.semrush.com/bot.html)
                """,
                expected:
                [
                    .single("Mozilla", 5, "0"),
                    .group(
                        "compatible",
                        "SemrushBot/7~bl",
                        "+http://www.semrush.com/bot.html"),
                ])
        }
        if  let tests:TestGroup = tests / "PixelImposter"
        {
            Self.run(tests,
                parsing: """
                Mozilla/5.0 (Linux; Android 8.0; Pixel 2 Build/OPD3.170816.012) \
                AppleWebKit/537.36 (KHTML, like Gecko) \
                Chrome/47.0.1610.1769 Mobile Safari/537.36
                """,
                expected:
                [
                    .single("Mozilla", 5, "0"),
                    .group("Linux", "Android 8.0", "Pixel 2 Build/OPD3.170816.012"),
                    .single("AppleWebKit", 537, "36"),
                    .group("KHTML, like Gecko"),
                    .single("Chrome", 47, "0.1610.1769"),
                    .single("Mobile"),
                    .single("Safari", 537, "36"),
                ])
        }
        if  let tests:TestGroup = tests / "iPhoneImposter"
        {
            Self.run(tests,
                parsing: """
                Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/537.36 \
                (KHTML, like Gecko) Chrome/53.0.2012.1059 Mobile Safari/537.36
                """,
                expected:
                [
                    .single("Mozilla", 5, "0"),
                    .group("iPhone", "CPU iPhone OS 11_0 like Mac OS X"),
                    .single("AppleWebKit", 537, "36"),
                    .group("KHTML, like Gecko"),
                    .single("Chrome", 53, "0.2012.1059"),
                    .single("Mobile"),
                    .single("Safari", 537, "36"),
                ])
        }
        if  let tests:TestGroup = tests / "WindowsImposter"
        {
            Self.run(tests,
                parsing: """
                Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 \
                (KHTML, like Gecko) Chrome/76.0.2822.46 Safari/537.36
                """,
                expected:
                [
                    .single("Mozilla", 5, "0"),
                    .group("Windows NT 6.3", "Win64", "x64"),
                    .single("AppleWebKit", 537, "36"),
                    .group("KHTML, like Gecko"),
                    .single("Chrome", 76, "0.2822.46"),
                    .single("Safari", 537, "36"),
                ])
        }
    }
}
