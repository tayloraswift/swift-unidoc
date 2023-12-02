import BSON
import MongoQL

extension Account
{
    @frozen public
    struct Cookie:Equatable, Hashable, Sendable
    {
        @usableFromInline internal
        let id:Account.ID
        @usableFromInline internal
        let cookie:Int64

        @inlinable internal
        init(id:Account.ID, cookie:Int64)
        {
            self.id = id
            self.cookie = cookie
        }
    }
}
extension Account.Cookie:CustomStringConvertible
{
    @inlinable public
    var description:String { "\(self.id):\(UInt64.init(bitPattern: self.cookie))" }
}
extension Account.Cookie:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:some StringProtocol)
    {
        if  let colon:String.Index = description.firstIndex(of: ":"),
            let id:Account.ID = .init(description[..<colon]),
            let cookie:UInt64 = .init(description[description.index(after: colon)...])
        {
            self.init(id: id, cookie: .init(bitPattern: cookie))
        }
        else
        {
            return nil
        }
    }
}
extension Account.Cookie:BSONDocumentDecodable
{
    public
    typealias CodingKey = Account.CodingKey

    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(), cookie: try bson[.cookie].decode())
    }
}
