@frozen public
enum MediaType:Equatable, Hashable, Sendable
{
    case multipart  (MultipartType, boundary:String)

    case application(MediaSubtype, charset:MediaEncoding? = nil)
    case audio      (MediaSubtype, charset:MediaEncoding? = nil)
    case font       (MediaSubtype, charset:MediaEncoding? = nil)
    case image      (MediaSubtype, charset:MediaEncoding? = nil)
    case model      (MediaSubtype, charset:MediaEncoding? = nil)
    case text       (MediaSubtype, charset:MediaEncoding? = nil)
    case video      (MediaSubtype, charset:MediaEncoding? = nil)
}
extension MediaType:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        switch self
        {
        case .multipart  (let subtype, boundary: let boundary):
            return "multipart/\(subtype); boundary=\(boundary)"

        case .application(let subtype, charset: nil):
            return "application/\(subtype)"

        case .application(let subtype, charset: let encoding?):
            return "application/\(subtype); charset=\(encoding)"

        case .audio      (let subtype, charset: nil):
            return "audio/\(subtype)"

        case .audio      (let subtype, charset: let encoding?):
            return "audio/\(subtype); charset=\(encoding)"

        case .font       (let subtype, charset: nil):
            return "font/\(subtype)"

        case .font       (let subtype, charset: let encoding?):
            return "font/\(subtype); charset=\(encoding)"

        case .image      (let subtype, charset: nil):
            return "image/\(subtype)"

        case .image      (let subtype, charset: let encoding?):
            return "image/\(subtype); charset=\(encoding)"

        case .model      (let subtype, charset: nil):
            return "model/\(subtype)"

        case .model      (let subtype, charset: let encoding?):
            return "model/\(subtype); charset=\(encoding)"

        case .text       (let subtype, charset: nil):
            return "text/\(subtype)"

        case .text       (let subtype, charset: let encoding?):
            return "text/\(subtype); charset=\(encoding)"

        case .video      (let subtype, charset: nil):
            return "video/\(subtype)"

        case .video      (let subtype, charset: let encoding?):
            return "video/\(subtype); charset=\(encoding)"

        }
    }
}
