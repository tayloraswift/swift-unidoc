import BSON

extension SwiftVersion {
    @frozen public enum Nightly: String, Equatable, Sendable {
        case DEVELOPMENT_SNAPSHOT = "DEVELOPMENT-SNAPSHOT"
    }
}
extension SwiftVersion.Nightly: BSONDecodable, BSONEncodable {
}
