import JSON

extension GitHub {
    @frozen public struct PersonalAccessToken: RawRepresentable, Sendable {
        public let rawValue: String

        @inlinable public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}
extension GitHub.PersonalAccessToken: ExpressibleByStringLiteral {
    @inlinable public init(stringLiteral: String) { self.init(rawValue: stringLiteral) }
}
extension GitHub.PersonalAccessToken: CustomStringConvertible {
    @inlinable public var description: String { self.rawValue }
}
extension GitHub.PersonalAccessToken: JSONEncodable, JSONDecodable {
}
