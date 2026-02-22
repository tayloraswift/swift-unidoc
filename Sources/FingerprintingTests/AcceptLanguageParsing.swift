import Fingerprinting
import HTTP
import Testing

@Suite struct AcceptLanguageParsing {
    @Test static func Empty() {
        let header: HTTP.AcceptLanguage = ""
        #expect([_].init(header) == [])
        #expect(header.dominant == nil)
    }
    @Test static func Wildcard() {
        let header: HTTP.AcceptLanguage = "*"
        #expect(header.dominant == nil)
        #expect(
            [_].init(header) == [
                .init(locale: nil, q: 1.0),
            ]
        )
    }
    @Test static func English() {
        let header: HTTP.AcceptLanguage = "en"
        #expect(header.dominant == .init(language: .en))
        #expect(
            [_].init(header) == [
                .init(locale: .init(language: .en), q: 1.0),
            ]
        )
    }
    @Test static func EnglishUS() {
        let header: HTTP.AcceptLanguage = "en-US"
        #expect(header.dominant == .init(language: .en, country: .US))
        #expect(
            [_].init(header) == [
                .init(locale: .init(language: .en, country: .US), q: 1.0),
            ]
        )
    }
    @Test static func MultipleChoices() {
        let header: HTTP.AcceptLanguage = "fr-CH, fr;q=0.9, en;q=0.8, de;q=0.7, *;q=0.5"
        #expect(header.dominant == .init(language: .fr, country: .CH))
        #expect(
            [_].init(header) == [
                .init(locale: .init(language: .fr, country: .CH), q: 1.0),
                .init(locale: .init(language: .fr), q: 0.9),
                .init(locale: .init(language: .en), q: 0.8),
                .init(locale: .init(language: .de), q: 0.7),
                .init(locale: nil, q: 0.5),
            ]
        )
    }
    @Test static func MultipleChoicesCompact() {
        let header: HTTP.AcceptLanguage = "fr-CH,fr;q=0.9,en;q=0.8,de;q=0.7,*;q=0.5"
        #expect(header.dominant == .init(language: .fr, country: .CH))
        #expect(
            [_].init(header) == [
                .init(locale: .init(language: .fr, country: .CH), q: 1.0),
                .init(locale: .init(language: .fr), q: 0.9),
                .init(locale: .init(language: .en), q: 0.8),
                .init(locale: .init(language: .de), q: 0.7),
                .init(locale: nil, q: 0.5),
            ]
        )
    }
    @Test static func MultipleChoicesDenormalized() {
        let header: HTTP.AcceptLanguage = " en-US;q=0.1  ,fr-CH,, fr;;q=0.9;, en;q=0.8 "
        #expect(header.dominant == .init(language: .fr, country: .CH))
        #expect(
            [_].init(header) == [
                .init(locale: .init(language: .en, country: .US), q: 0.1),
                .init(locale: .init(language: .fr, country: .CH), q: 1.0),
                .init(locale: .init(language: .fr), q: 0.9),
                .init(locale: .init(language: .en), q: 0.8),
            ]
        )
    }
}
