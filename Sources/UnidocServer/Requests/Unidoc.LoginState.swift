import URI

extension Unidoc
{
    @frozen public
    struct LoginState:Sendable
    {
        public
        let cookies:Cookies
        public
        let request:URI

        @inlinable public
        init(cookies:Cookies, request:URI)
        {
            self.cookies = cookies
            self.request = request
        }
    }
}
