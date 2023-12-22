import JSON

extension GitHub.OAuth
{
    @frozen public
    struct Credentials
    {
        public
        let token:String
        public
        let scope:String?

        @inlinable public
        init(token:String, scope:String?)
        {
            self.token = token
            self.scope = scope
        }
    }
}
extension GitHub.OAuth.Credentials:JSONObjectDecodable
{
    public
    enum CodingKey:String, Sendable
    {
        case token = "access_token"
        case scope
    }

    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(
            token: try json[.token].decode(),
            scope: try json[.scope]?.decode())
    }
}
