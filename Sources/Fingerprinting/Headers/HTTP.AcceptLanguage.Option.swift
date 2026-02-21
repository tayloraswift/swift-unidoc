import HTTP
import ISO

extension HTTP.AcceptLanguage {
    @frozen public struct Option: Equatable, Hashable, Sendable {
        /// The `accept-language` locale, or `nil` for the wildcard (`*`).
        public let locale: ISO.Locale?
        public let q: Double

        @inlinable public init(locale: ISO.Locale?, q: Double) {
            self.locale = locale
            self.q = q
        }
    }
}
