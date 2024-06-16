import HTTP
import Testing_
import Fingerprinting

extension Main
{
    struct AcceptLanguageParsing
    {
    }
}
extension Main.AcceptLanguageParsing:TestBattery
{
    static
    func run(tests:TestGroup)
    {
        if  let tests:TestGroup = tests / "Empty"
        {
            let header:HTTP.AcceptLanguage = ""
            tests.expect(header ..? [])
            tests.expect(nil: header.dominant)
        }
        if  let tests:TestGroup = tests / "Wildcard"
        {
            let header:HTTP.AcceptLanguage = "*"
            tests.expect(nil: header.dominant)
            tests.expect(header ..? [
                .init(locale: nil, q: 1.0),
            ])
        }
        if  let tests:TestGroup = tests / "English"
        {
            let header:HTTP.AcceptLanguage = "en"
            tests.expect(header.dominant ==? .init(language: .en))
            tests.expect(header ..? [
                .init(locale: .init(language: .en), q: 1.0),
            ])
        }
        if  let tests:TestGroup = tests / "EnglishUS"
        {
            let header:HTTP.AcceptLanguage = "en-US"
            tests.expect(header.dominant ==? .init(language: .en, country: .us))
            tests.expect(header ..? [
                .init(locale: .init(language: .en, country: .us), q: 1.0),
            ])
        }
        if  let tests:TestGroup = tests / "MultipleChoices"
        {
            let header:HTTP.AcceptLanguage = "fr-CH, fr;q=0.9, en;q=0.8, de;q=0.7, *;q=0.5"
            tests.expect(header.dominant ==? .init(language: .fr, country: .ch))
            tests.expect(header ..? [
                .init(locale: .init(language: .fr, country: .ch), q: 1.0),
                .init(locale: .init(language: .fr), q: 0.9),
                .init(locale: .init(language: .en), q: 0.8),
                .init(locale: .init(language: .de), q: 0.7),
                .init(locale: nil, q: 0.5),
            ])
        }
        if  let tests:TestGroup = tests / "MultipleChoicesCompact"
        {
            let header:HTTP.AcceptLanguage = "fr-CH,fr;q=0.9,en;q=0.8,de;q=0.7,*;q=0.5"
            tests.expect(header.dominant ==? .init(language: .fr, country: .ch))
            tests.expect(header ..? [
                .init(locale: .init(language: .fr, country: .ch), q: 1.0),
                .init(locale: .init(language: .fr), q: 0.9),
                .init(locale: .init(language: .en), q: 0.8),
                .init(locale: .init(language: .de), q: 0.7),
                .init(locale: nil, q: 0.5),
            ])
        }
        if  let tests:TestGroup = tests / "MultipleChoicesDenormalized"
        {
            let header:HTTP.AcceptLanguage = " en-US;q=0.1  ,fr-CH,, fr;;q=0.9;, en;q=0.8 "
            tests.expect(header.dominant ==? .init(language: .fr, country: .ch))
            tests.expect(header ..? [
                .init(locale: .init(language: .en, country: .us), q: 0.1),
                .init(locale: .init(language: .fr, country: .ch), q: 1.0),
                .init(locale: .init(language: .fr), q: 0.9),
                .init(locale: .init(language: .en), q: 0.8),
            ])
        }
    }
}
