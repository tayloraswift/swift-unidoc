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
        /// This is only used for display purposes.
        public
        let symbol:String?

        @inlinable
        init(account:Account, cookie:Int64, apiKey:Int64?, symbol:String?)
        {
            self.account = account
            self.cookie = cookie
            self.apiKey = apiKey
            self.symbol = symbol
        }
    }
}
extension Unidoc.UserSecrets
{
    @inlinable public
    var web:Unidoc.UserSession.Web?
    {
        self.symbol.map { .init(id: self.account, cookie: self.cookie, symbol: $0) }
    }

    @inlinable public
    var api:Unidoc.UserSession.API?
    {
        self.apiKey.map { .init(id: self.account, apiKey: $0) }
    }
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
            apiKey: try bson[.apiKey]?.decode(),
            symbol: try bson[.symbol]?.decode())
    }
}
