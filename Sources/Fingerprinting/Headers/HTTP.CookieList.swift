import HTTP

extension HTTP {
    @frozen public struct CookieList: Header, Sendable, ExpressibleByStringLiteral {
        public var rawValue: Substring

        @inlinable public init(rawValue: Substring) {
            self.rawValue = rawValue
        }
    }
}
extension HTTP.CookieList: Sequence {
    @inlinable public func makeIterator() -> Iterator {
        .init(parser: .init(string: self.rawValue))
    }
}
