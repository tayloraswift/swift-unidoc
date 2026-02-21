extension AWS {
    @frozen public struct AccessKey: Identifiable, Hashable, Sendable {
        public var id: String
        public var secret: String

        @inlinable public init(id: String, secret: String) {
            self.id = id
            self.secret = secret
        }
    }
}
