import BSON
import MongoQL
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct Cookie:Equatable, Hashable, Sendable
    {
        public
        let user:User.ID
        @usableFromInline internal
        let cookie:Int64

        @inlinable internal
        init(user:User.ID, cookie:Int64)
        {
            self.user = user
            self.cookie = cookie
        }
    }
}
extension Unidoc.Cookie:CustomStringConvertible
{
    @inlinable public
    var description:String { "\(self.user)_\(UInt64.init(bitPattern: self.cookie))" }
}
extension Unidoc.Cookie:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:some StringProtocol)
    {
        if  let colon:String.Index = description.firstIndex(of: "_"),
            let user:Unidoc.User.ID = .init(description[..<colon]),
            let cookie:UInt64 = .init(description[description.index(after: colon)...])
        {
            self.init(user: user, cookie: .init(bitPattern: cookie))
        }
        else
        {
            return nil
        }
    }
}
extension Unidoc.Cookie:BSONDocumentDecodable
{
    public
    typealias CodingKey = Unidoc.User.CodingKey

    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(user: try bson[.id].decode(), cookie: try bson[.cookie].decode())
    }
}
