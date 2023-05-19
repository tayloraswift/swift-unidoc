@frozen public
enum MediaSubtype:String, Equatable, Hashable, Sendable
{
    case apng
    case avif
    case css
    case gif
    case html
    case icon = "x-icon"
    case javascript
    case jpeg
    case json
    case markdown
    case octetStream = "octet-stream"
    case ogg
    case otf
    case plain
    case png
    case rss = "rss+xml"
    case svg = "svg+xml"
    case ttf
    case wav
    case webm
    case webp
    case woff
    case woff2
}
extension MediaSubtype:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.rawValue
    }
}
extension MediaSubtype:LosslessStringConvertible
{
    /// Intelligently detects a media subtype from a string, handling deprecated
    /// and alternate spellings. Prefer this API over ``init(rawValue:)``.
    @inlinable public
    init?(_ description:String)
    {
        self.init(lowercased: description.lowercased())
    }

    @inlinable public
    init?(lowercased description:String)
    {
        if  let value:Self = .init(rawValue: description)
        {
            self = value
            return
        }
        switch description
        {
        case "wav", "x-wav", "x-pn-wav":
            self = .wav
        case "ecmascript", "x-ecmascript", "x-javascript", "jscript", "livescript":
            self = .javascript
        case "font/ttf":
            self = .ttf
        case "image/png":
            self = .png
        case "image/x-icon":
            self = .icon
        case _:
            return nil
        }
    }
}
extension MediaSubtype
{
    /// Returns a sensible file extension for this media subtype, such as `"md"`
    /// for ``markdown`` text.
    @inlinable public
    var `extension`:String
    {
        switch self
        {
        case .apng:         return "apng"
        case .avif:         return "avif"
        case .css:          return "css"
        case .gif:          return "gif"
        case .html:         return "html"
        case .icon:         return "ico"
        case .javascript:   return "js"
        case .jpeg:         return "jpeg"
        case .json:         return "json"
        case .markdown:     return "md"
        case .octetStream:  return "bin"
        case .ogg:          return "ogg"
        case .otf:          return "otf"
        case .plain:        return "txt"
        case .png:          return "png"
        case .rss:          return "rss"
        case .svg:          return "svg"
        case .ttf:          return "ttf"
        case .wav:          return "wav"
        case .webm:         return "webm"
        case .webp:         return "webp"
        case .woff:         return "woff"
        case .woff2:        return "woff2"
        }
    }
}
