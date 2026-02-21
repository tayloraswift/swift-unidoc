import JSON

extension GitHub {
    @frozen public struct Node: RawRepresentable, Equatable, Hashable, Sendable {
        public let rawValue: String

        @inlinable public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}
extension GitHub.Node: CustomStringConvertible {
    @inlinable public var description: String { self.rawValue }
}
extension GitHub.Node: LosslessStringConvertible {
    @inlinable public init(_ description: String) { self.init(rawValue: description) }
}
extension GitHub.Node: ExpressibleByStringLiteral {
    @inlinable public init(stringLiteral: String) { self.init(rawValue: stringLiteral) }
}
extension GitHub.Node: JSONEncodable, JSONDecodable {
}
