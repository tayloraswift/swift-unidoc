extension Symbol {
    /// A type abstraction that wraps a ``String``. This module does not define
    /// any particular format or content restrictions for article identifiers.
    ///
    /// This type performs comparisons using the default ``String``
    /// implementation, which is a unicode-aware string comparison.
    @frozen public struct Article: RawRepresentable, Equatable, Hashable, Sendable {
        public let rawValue: String

        @inlinable public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}
extension Symbol.Article: Comparable {
    @inlinable public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
