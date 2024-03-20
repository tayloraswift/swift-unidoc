import BSON
import UnidocRecords

extension Unidoc.DB.Users
{
    struct LimitView:Equatable, Sendable
    {
        let id:Unidoc.Account
        let apiLimitLeft:Int

        init(id:Unidoc.Account, apiLimitLeft:Int)
        {
            self.id = id
            self.apiLimitLeft = apiLimitLeft
        }
    }
}
extension Unidoc.DB.Users.LimitView:BSONDocumentDecodable
{
    typealias CodingKey = Unidoc.User.CodingKey

    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(id: try bson[.id].decode(), apiLimitLeft: try bson[.apiLimitLeft].decode())
    }
}
