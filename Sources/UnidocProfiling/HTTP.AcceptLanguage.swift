import HTTP

extension HTTP
{
    @frozen public
    struct AcceptLanguage:Equatable, Hashable, Sendable
    {
        public
        let dominant:Substring

        @inlinable public
        init(dominant:Substring)
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

        if  dominant.subtag.isEmpty
        {
            return nil
        }

        self.init(dominant: dominant.subtag)
    }
}
extension HTTP.AcceptLanguage
{
    @inlinable internal
    var field:WritableKeyPath<ServerProfile.ByLanguage, Int>
    {
        switch self.dominant
        {
        case "ar":  return \.ar
        case "bn":  return \.bn
        case "de":  return \.de
        case "en":  return \.en
        case "es":  return \.es
        case "fr":  return \.fr
        case "hi":  return \.hi
        case "it":  return \.it
        case "ja":  return \.ja
        case "ko":  return \.ko
        case "pt":  return \.pt
        case "ru":  return \.ru
        case "vi":  return \.vi
        case "zh":  return \.zh
        case _:     return \.other
        }
    }
}
