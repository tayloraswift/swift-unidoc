import MD5
import Media

extension HTTP {
    @frozen public struct Resource: Equatable, Sendable {
        public let headers: Headers
        public var content: Content?
        public var hash: MD5?

        @inlinable public init(
            headers: Headers = .init(),
            content: Content?,
            hash: MD5? = nil
        ) {
            self.headers = headers
            self.content = content
            self.hash = hash
        }
    }
}
extension HTTP.Resource: ExpressibleByStringLiteral, ExpressibleByStringInterpolation {
    @inlinable public init(stringLiteral: String) {
        self.init(
            content: .init(
                body: .string(stringLiteral),
                type: .text(.plain, charset: .utf8)
            )
        )
    }
}
