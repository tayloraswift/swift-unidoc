import BSON

extension Unidoc.DB.Metadata {
    @frozen public enum Key: Int32, Sendable {
        case packages_json  = 0x0000
        case robots_txt     = 0x1000
    }
}
extension Unidoc.DB.Metadata.Key: BSONDecodable, BSONEncodable {
}
