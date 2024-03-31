extension Swiftinit
{
    struct Credentials:Sendable
    {
        let cookies:Cookies
        let request:String

        init(cookies:Cookies, request:String)
        {
            self.cookies = cookies
            self.request = request
        }
    }
}
