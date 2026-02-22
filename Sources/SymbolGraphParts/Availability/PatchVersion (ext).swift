import JSONDecoding
import SemanticVersions

extension PatchVersion: JSONObjectDecodable {
    public enum CodingKey: String, Sendable {
        case major
        case minor
        case patch
    }

    public init(json: JSON.ObjectDecoder<CodingKey>) throws {
        self = .v(
            try json[.major].decode(),
            try json[.minor].decode(),
            try json[.patch].decode()
        )
    }
}
