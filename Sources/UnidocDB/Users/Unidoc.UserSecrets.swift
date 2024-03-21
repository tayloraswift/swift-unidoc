import BSON
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct UserSecrets:Equatable, Hashable, Sendable
    {
        public
        let account:Account
        public
        let cookie:Int64
        public
        let apiKey:Int64?

        @inlinable
        init(account:Account, cookie:Int64, apiKey:Int64?)
        {
            self.account = account
            self.cookie = cookie
            self.apiKey = apiKey
        }
    }
}
extension Unidoc.UserSecrets
{
    @inlinable public
    var session:Unidoc.UserSession { .init(account: account, cookie: cookie) }
}
extension Unidoc.UserSecrets:BSONDocumentDecodable
{
    public
    typealias CodingKey = Unidoc.User.CodingKey

    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(account: try bson[.id].decode(),
            cookie: try bson[.cookie].decode(),
            apiKey: try bson[.apiKey]?.decode())
    }
}
