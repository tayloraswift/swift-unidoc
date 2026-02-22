import BSON
import Unidoc

extension Unidoc {
    @frozen public struct Realm: RawRepresentable, Equatable, Hashable, Sendable {
        public let rawValue: Int32

        @inlinable public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}
extension Unidoc.Realm: ExpressibleByIntegerLiteral {
    @inlinable public init(integerLiteral: Int32) { self.init(rawValue: integerLiteral) }
}
extension Unidoc.Realm {
    @inlinable public static var united: Self { .init(rawValue: 0) }
}
extension Unidoc.Realm: BSONDecodable, BSONEncodable {
}
