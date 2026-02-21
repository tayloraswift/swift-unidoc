extension HTTP {
    /// https://stackoverflow.com/questions/2081645/what-do-you-call-the-entire-first-part-of-a-url
    @frozen public struct ServerOrigin: Sendable {
        /// The string value of the authority, including the port if not the default.
        /// Does not include the scheme.
        ///
        /// See: https://en.wikipedia.org/wiki/Uniform_Resource_Identifier#Example_URIs
        public let authority: String
        public let scheme: Scheme

        @inlinable public init(scheme: Scheme, authority: String) {
            self.authority = authority
            self.scheme = scheme
        }
    }
}
extension HTTP.ServerOrigin {
    @inlinable public static func https(host: String, port: Int = 443) -> Self {
        .init(scheme: .https, authority: port == 443 ? host : "\(host):\(port)")
    }

    @inlinable public static func http(host: String, port: Int = 80) -> Self {
        .init(scheme: .http, authority: port == 80 ? host : "\(host):\(port)")
    }
}
extension HTTP.ServerOrigin: CustomStringConvertible {
    /// Formats the origin as a string, including the scheme, and the port if present, but not
    /// including any trailing slash.
    @inlinable public var description: String { "\(self.scheme.name)://\(self.authority)" }
}
