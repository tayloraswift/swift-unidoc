import BSON

extension Unidoc {
    @frozen public struct PackageSettings: Equatable, Sendable {
        public var theme: String?

        @inlinable public init(theme: String? = nil) {
            self.theme = theme
        }
    }
}
extension Unidoc.PackageSettings {
    @frozen public enum CodingKey: String, Sendable {
        case theme = "T"
    }
}
extension Unidoc.PackageSettings: BSONDocumentEncodable {
    public func encode(to bson: inout BSON.DocumentEncoder<CodingKey>) {
        bson[.theme] = self.theme
    }
}
extension Unidoc.PackageSettings: BSONDocumentDecodable {
    @inlinable public init(bson: BSON.DocumentDecoder<CodingKey>) throws {
        self.init(theme: try bson[.theme]?.decode())
    }
}
