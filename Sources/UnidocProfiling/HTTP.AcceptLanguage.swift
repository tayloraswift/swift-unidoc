import HTTP
import Media

extension HTTP
{
    @frozen public
    struct AcceptLanguage:Equatable, Hashable, Sendable
    {
        public
        let dominant:Macrolanguage

        @inlinable public
        init(dominant:Macrolanguage)
        {
            self.dominant = dominant
        }
    }
}
extension HTTP.AcceptLanguage
{
    public
    init?(_ string:String)
    {
        var dominant:(subtag:Substring, quality:Double) = ("", 0.0)

        for language:Substring in string.split(separator: ",")
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

        guard
        let macrolanguage:Macrolanguage = .init(dominant.subtag)
        else
        {
            return nil
        }

        self.init(dominant: macrolanguage)
    }
}
