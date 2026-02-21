@frozen public enum MediaType: Equatable, Hashable, Sendable {
    case application(MediaSubtype, charset: Charset? = nil)
    case audio      (MediaSubtype, charset: Charset? = nil)
    case font       (MediaSubtype, charset: Charset? = nil)
    case image      (MediaSubtype, charset: Charset? = nil)
    case model      (MediaSubtype, charset: Charset? = nil)
    case text       (MediaSubtype, charset: Charset? = nil)
    case video      (MediaSubtype, charset: Charset? = nil)
}
extension MediaType: CustomStringConvertible {
    @inlinable public var description: String {
        switch self {
        case .application(let subtype, charset: nil):
            "application/\(subtype)"

        case .application(let subtype, charset: let encoding?):
            "application/\(subtype); charset=\(encoding)"

        case .audio      (let subtype, charset: nil):
            "audio/\(subtype)"

        case .audio      (let subtype, charset: let encoding?):
            "audio/\(subtype); charset=\(encoding)"

        case .font       (let subtype, charset: nil):
            "font/\(subtype)"

        case .font       (let subtype, charset: let encoding?):
            "font/\(subtype); charset=\(encoding)"

        case .image      (let subtype, charset: nil):
            "image/\(subtype)"

        case .image      (let subtype, charset: let encoding?):
            "image/\(subtype); charset=\(encoding)"

        case .model      (let subtype, charset: nil):
            "model/\(subtype)"

        case .model      (let subtype, charset: let encoding?):
            "model/\(subtype); charset=\(encoding)"

        case .text       (let subtype, charset: nil):
            "text/\(subtype)"

        case .text       (let subtype, charset: let encoding?):
            "text/\(subtype); charset=\(encoding)"

        case .video      (let subtype, charset: nil):
            "video/\(subtype)"

        case .video      (let subtype, charset: let encoding?):
            "video/\(subtype); charset=\(encoding)"
        }
    }
}
