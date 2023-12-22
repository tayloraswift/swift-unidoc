import JSON

extension GitHub.App
{
    @frozen public
    struct Credentials:Equatable, Hashable, Sendable
    {
        public
        let refresh:Token
        public
        let access:Token

        @inlinable public
        init(refresh:Token, access:Token)
        {
            self.refresh = refresh
            self.access = access
        }
    }
}
extension GitHub.App.Credentials:JSONObjectDecodable
{
    public
    enum CodingKey:String, Sendable
    {
        case access_value = "access_token"
        case access_secondsRemaining = "expires_in"
        case refresh_value = "refresh_token"
        case refresh_secondsRemaining = "refresh_token_expires_in"
    }

    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(
            refresh: .init(value: try json[.refresh_value].decode(),
                secondsRemaining: try json[.refresh_secondsRemaining].decode()),
            access:  .init(value: try json[.access_value].decode(),
                secondsRemaining: try json[.access_secondsRemaining].decode()))
    }
}
