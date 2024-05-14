import JSON

extension GitHub.App
{
    @frozen public
    struct Credentials:Equatable, Hashable, Sendable
    {
        public
        var accessToken:String
        public
        var accessTokenSecondsRemaining:Int64?
        public
        var refreshToken:String?
        public
        var refreshTokenSecondsRemaining:Int64?

        @inlinable public
        init(accessToken:String,
            accessTokenSecondsRemaining:Int64? = nil,
            refreshToken:String? = nil,
            refreshTokenSecondsRemaining:Int64? = nil)
        {
            self.accessToken = accessToken
            self.accessTokenSecondsRemaining = accessTokenSecondsRemaining
            self.refreshToken = refreshToken
            self.refreshTokenSecondsRemaining = refreshTokenSecondsRemaining
        }
    }
}
extension GitHub.App.Credentials:JSONObjectDecodable
{
    public
    enum CodingKey:String, Sendable
    {
        case accessToken = "access_token"
        case accessTokenSecondsRemaining = "expires_in"
        case refreshToken = "refresh_token"
        case refreshTokenSecondsRemaining = "refresh_token_expires_in"
    }

    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(accessToken: try json[.accessToken].decode(),
            accessTokenSecondsRemaining: try json[.accessTokenSecondsRemaining]?.decode(),
            refreshToken: try json[.refreshToken]?.decode(),
            refreshTokenSecondsRemaining: try json[.refreshTokenSecondsRemaining]?.decode())
    }
}
