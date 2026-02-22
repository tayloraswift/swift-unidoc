import HTTP

extension HTTP.Accept {
    @frozen public struct Option: Equatable, Hashable, Sendable {
        /// An `accept` media type. This is currently undertyped due to lack of media type
        /// definitions.
        public let type: Substring
        public let q: Double
        public let v: Substring?

        @inlinable public init(type: Substring, q: Double, v: Substring? = nil) {
            self.type = type
            self.q = q
            self.v = v
        }
    }
}
