import HTTP
import ISO

extension HTTP {
    @frozen public struct AcceptLanguage: Header, Sendable, ExpressibleByStringLiteral {
        public var rawValue: Substring

        @inlinable public init(rawValue: Substring) {
            self.rawValue = rawValue
        }
    }
}
extension HTTP.AcceptLanguage: Sequence {
    @inlinable public func makeIterator() -> Iterator {
        .init(parser: .init(string: self.rawValue))
    }
}
extension HTTP.AcceptLanguage {
    /// Returns the locale with the highest quality factor.
    @inlinable public var dominant: ISO.Locale? {
        self.max { $0.q < $1.q }?.locale
    }
}
