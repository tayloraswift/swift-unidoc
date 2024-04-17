extension Unidoc
{
    @frozen public
    struct Credentials:Sendable
    {
        public
        let cookies:Cookies
        public
        let request:String

        @inlinable public
        init(cookies:Cookies, request:String)
        {
            self.cookies = cookies
            self.request = request
        }
    }
}
