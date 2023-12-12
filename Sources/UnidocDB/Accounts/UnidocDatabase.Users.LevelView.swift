import BSON
import UnidocRecords

extension UnidocDatabase.Users
{
    struct LevelView:Equatable, Sendable
    {
        let id:Unidex.User.ID
        let level:Unidex.User.Level

        init(id:Unidex.User.ID, level:Unidex.User.Level)
        {
            self.id = id
            self.level = level
        }
    }
}
extension UnidocDatabase.Users.LevelView:BSONDocumentDecodable
{
    typealias CodingKey = Unidex.User.CodingKey

    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(),
            level: try bson[.level].decode())
    }
}
