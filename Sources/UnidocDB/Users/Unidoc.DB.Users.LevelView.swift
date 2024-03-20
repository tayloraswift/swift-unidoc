import BSON
import UnidocRecords

extension Unidoc.DB.Users
{
    struct LevelView:Equatable, Sendable
    {
        let id:Unidoc.Account
        let level:Unidoc.User.Level

        init(id:Unidoc.Account, level:Unidoc.User.Level)
        {
            self.id = id
            self.level = level
        }
    }
}
extension Unidoc.DB.Users.LevelView:BSONDocumentDecodable
{
    typealias CodingKey = Unidoc.User.CodingKey

    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(id: try bson[.id].decode(), level: try bson[.level].decode())
    }
}
