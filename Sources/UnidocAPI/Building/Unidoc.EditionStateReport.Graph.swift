import JSON
import SHA1
import SHA1_JSON

extension Unidoc.EditionStateReport {
    @frozen public struct Graph {
        public let action: Unidoc.LinkerAction?
        public let commit: SHA1?

        @inlinable public init(action: Unidoc.LinkerAction?, commit: SHA1?) {
            self.action = action
            self.commit = commit
        }
    }
}
extension Unidoc.EditionStateReport.Graph {
    @frozen public enum CodingKey: String, Sendable {
        case action
        case commit
    }
}
extension Unidoc.EditionStateReport.Graph: JSONObjectEncodable {
    public func encode(to json: inout JSON.ObjectEncoder<CodingKey>) {
        json[.action] = self.action
        json[.commit] = self.commit
    }
}
extension Unidoc.EditionStateReport.Graph: JSONObjectDecodable {
    public init(json: JSON.ObjectDecoder<CodingKey>) throws {
        self.init(action: try json[.action]?.decode(), commit: try json[.commit]?.decode())
    }
}
