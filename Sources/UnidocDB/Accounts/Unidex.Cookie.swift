import BSON
import MongoQL
import UnidocRecords

extension Unidex
{
    @frozen public
    struct Cookie:Equatable, Hashable, Sendable
    {
        @usableFromInline internal
        let id:User.ID
        @usableFromInline internal
        let cookie:Int64

        @inlinable internal
        init(id:User.ID, cookie:Int64)
        {
            self.id = id
            self.cookie = cookie
        }
    }
}
extension Unidex.Cookie:CustomStringConvertible
{
    @inlinable public
    var description:String { "\(self.id)_\(UInt64.init(bitPattern: self.cookie))" }
}
extension Unidex.Cookie:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:some StringProtocol)
    {
        if  let colon:String.Index = description.firstIndex(of: "_"),
            let id:Unidex.User.ID = .init(description[..<colon]),
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
extension Unidex.Cookie:BSONDocumentDecodable
{
    public
    typealias CodingKey = Unidex.User.CodingKey

    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(), cookie: try bson[.cookie].decode())
    }
}
