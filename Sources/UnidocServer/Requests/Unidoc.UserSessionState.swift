import URI

extension Unidoc
{
    @frozen public
    struct UserSessionState:Sendable
    {
        public
        let authorization:Authorization
        public
        let request:URI

        @inlinable public
        init(authorization:Authorization, request:URI)
        {
            self.authorization = authorization
            self.request = request
        }
    }
}
