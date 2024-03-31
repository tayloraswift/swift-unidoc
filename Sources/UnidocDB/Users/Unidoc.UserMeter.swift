import BSON
import UnidocRecords

extension Unidoc
{
    struct UserMeter:Equatable, Sendable
    {
        let id:Unidoc.Account
        let apiLimitLeft:Int
        let apiKey:Int64?

        init(id:Unidoc.Account, apiLimitLeft:Int, apiKey:Int64?)
        {
            self.id = id
            self.apiLimitLeft = apiLimitLeft
            self.apiKey = apiKey
        }
    }
}
extension Unidoc.UserMeter:BSONDocumentDecodable
{
    typealias CodingKey = Unidoc.User.CodingKey

    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(id: try bson[.id].decode(),
            apiLimitLeft: try bson[.apiLimitLeft].decode(),
            apiKey: try bson[.apiKey]?.decode())
    }
}
