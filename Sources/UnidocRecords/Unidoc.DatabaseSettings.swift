extension Unidoc {
    @frozen public struct DatabaseSettings {
        public let access: AccessControl

        public var apiLimitInterval: Duration
        public var apiLimitPerReset: Int

        @inlinable public init(access: AccessControl) {
            self.access = access

            self.apiLimitInterval = .seconds(15)
            self.apiLimitPerReset = 1
        }
    }
}
extension Unidoc.DatabaseSettings {
    @inlinable public init(
        access: Unidoc.AccessControl,
        configure: (inout Self) throws -> Void
    ) rethrows {
        self.init(access: access)
        try configure(&self)
    }
}
