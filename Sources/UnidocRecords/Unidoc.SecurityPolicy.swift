extension Unidoc
{
    @frozen public
    struct SecurityPolicy
    {
        public
        let security:Security

        public
        var apiLimitInterval:Duration
        public
        var apiLimitPerReset:Int

        @inlinable public
        init(security:Security)
        {
            self.security = security

            self.apiLimitInterval = .seconds(15)
            self.apiLimitPerReset = 1
        }
    }
}
extension Unidoc.SecurityPolicy
{
    @inlinable public
    init(security:Unidoc.Security, configure:(inout Self) throws -> Void) rethrows
    {
        self.init(security: security)
        try configure(&self)
    }
}
