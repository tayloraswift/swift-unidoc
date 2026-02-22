import HTTP
import ISO

extension HTTP.AcceptLanguage {
    @frozen public struct Iterator {
        @usableFromInline var parser: HTTP.HeaderWords<HTTP.AcceptStringParameter, HTTP.Comma>

        @inlinable init(parser: HTTP.HeaderWords<HTTP.AcceptStringParameter, HTTP.Comma>) {
            self.parser = parser
        }
    }
}
extension HTTP.AcceptLanguage.Iterator: IteratorProtocol {
    @inlinable public mutating func next() -> HTTP.AcceptLanguage.Option? {
        while let parameter: HTTP.AcceptStringParameter = self.parser.next() {
            let language: Substring
            let country: ISO.Country?

            if  let hyphen: String.Index = parameter.key.firstIndex(of: "-") {
                let i: String.Index = parameter.key.index(after: hyphen)

                language = parameter.key[..<hyphen]
                country = .init(parameter.key[i...])
            } else {
                language = parameter.key
                country = nil
            }

            let locale: ISO.Locale?

            if  let language: ISO.Macrolanguage = .init(language) {
                locale = .init(language: language, country: country)
            } else if language == "*" {
                locale = nil
            } else {
                continue
            }

            return .init(locale: locale, q: parameter.q ?? 1.0)
        }

        return nil
    }
}
