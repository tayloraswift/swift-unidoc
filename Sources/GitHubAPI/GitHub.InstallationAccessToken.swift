import JSON

extension GitHub {
    @frozen public struct InstallationAccessToken: RawRepresentable, Sendable {
        public let rawValue: String

        @inlinable public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}
extension GitHub.InstallationAccessToken: ExpressibleByStringLiteral {
    @inlinable public init(stringLiteral: String) { self.init(rawValue: stringLiteral) }
}
extension GitHub.InstallationAccessToken: CustomStringConvertible {
    @inlinable public var description: String { self.rawValue }
}
extension GitHub.InstallationAccessToken: JSONEncodable, JSONDecodable {
}
