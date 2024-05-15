import BSON
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct UserRights:Equatable, Sendable
    {
        public
        let access:[Account]
        public
        let level:User.Level

        @inlinable public
        init(access:[Account] = [], level:Unidoc.User.Level = .human)
        {
            self.access = access
            self.level = level
        }
    }
}
extension Unidoc.UserRights:BSONDocumentDecodable
{
    public
    typealias CodingKey = Unidoc.User.CodingKey

    public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(access: try bson[.access]?.decode() ?? [], level: try bson[.level].decode())
    }
}
