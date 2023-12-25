import HTTP
import ISO

extension HTTP
{
    @frozen public
    struct AcceptLanguage:Equatable, Hashable, Sendable
    {
        public
        var tags:[Tag]

        @inlinable public
        init(tags:[Tag])
        {
            self.tags = tags
        }
    }
}
extension HTTP.AcceptLanguage:ExpressibleByArrayLiteral
{
    @inlinable public
    init(arrayLiteral:Tag...) { self.init(tags: arrayLiteral) }
}
extension HTTP.AcceptLanguage
{
    public
    init?(_ string:String)
    {
        self = []

        if  string == "*"
        {
            return
        }

        for language:Substring in string.split(separator: ",")
        {
            let language:Substring = language.drop(while: \.isWhitespace)

            let semicolon:String.Index?

            let macrolanguage:ISO.Macrolanguage?
            let country:ISO.Country?

            if  let hyphen:String.Index = language.firstIndex(of: "-")
            {
                let i:String.Index = language.index(after: hyphen)

                semicolon = language[i...].firstIndex(of: ";")

                macrolanguage = .init(language[..<hyphen])
                country = .init(language[i ..< (semicolon ?? language.endIndex)].lowercased())
            }
            else
            {
                semicolon = language.firstIndex(of: ";")

                macrolanguage = .init(language[..<(semicolon ?? language.endIndex)])
                country = nil
            }

            guard
            let macrolanguage:ISO.Macrolanguage
            else
            {
                continue
            }

            var quality:Double = 1.0

            defer
            {
                self.tags.append(.init(
                    locale: .init(language: macrolanguage, country: country),
                    q: quality))
            }

            guard
            let semicolon:String.Index
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

        if  self.tags.isEmpty
        {
            return nil
        }
    }
}
extension HTTP.AcceptLanguage
{
    @inlinable public
    var dominant:HTTP.Locale?
    {
        self.tags.max { $0.q < $1.q }?.locale
    }
}
