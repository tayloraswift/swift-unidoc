import Sources

extension Markdown
{
    @frozen public
    struct ExternalURL
    {
        public
        var scheme:String
        public
        var suffix:SourceString

        @inlinable public
        init(scheme:String, suffix:SourceString)
        {
            self.scheme = scheme
            self.suffix = suffix
        }
    }
}
extension Markdown.ExternalURL:CustomStringConvertible
{
    @inlinable public
    var description:String { "\(self.scheme):\(self.suffix)" }
}
extension Markdown.ExternalURL
{
    @usableFromInline
    init?(from url:Markdown.SourceString)
    {
        //  URL parsing is incredibly tough.
        //
        //  This problem is complicated significantly by the fact that Apple uses a
        //  [non-standard](https://www.iana.org/assignments/uri-schemes/uri-schemes.xhtml)
        //  `doc:` scheme for documentation links.
        //
        //  We need to do this in order to avoid emitting unresolved relative URLs, as such
        //  URLs would never work properly for the user.
        guard
        let colon:String.Index = url.string.firstIndex(of: ":")
        else
        {
            return nil
        }

        scheme:
        for codepoint:Unicode.Scalar in url.string.unicodeScalars[..<colon]
        {
            switch codepoint
            {
            case "+":           continue
            case "-":           continue
            case ".":           continue
            case "0" ... "9":   continue
            case "A" ... "Z":   continue
            case "a" ... "z":   continue
            //  This isn’t a scheme at all!
            default:            return nil
            }
        }

        let scheme:String = .init(url.string[..<colon])
        var suffix:Markdown.SourceString = consume url
            suffix.string.removeSubrange(...colon)

        self.init(scheme: scheme, suffix: suffix)
    }
}
