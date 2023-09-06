import BSONDecoding

extension Account.Database.Users
{
    struct CookieView:Equatable, Sendable
    {
        let cookie:Int64

        init(cookie:Int64)
        {
            self.cookie = cookie
        }
    }
}
extension Account.Database.Users.CookieView:BSONDocumentDecodable
{
    typealias CodingKey = Account.CodingKey

    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(cookie: try bson[.cookie].decode())
    }
}
