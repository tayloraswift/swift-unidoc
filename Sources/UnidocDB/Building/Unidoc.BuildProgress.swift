import BSON
import MongoQL
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct BuildProgress:Equatable, Sendable
    {
        public
        var started:BSON.Millisecond
        public
        var builder:Unidoc.Account

        @inlinable public
        init(started:BSON.Millisecond, builder:Unidoc.Account)
        {
            self.started = started
            self.builder = builder
        }
    }
}
extension Unidoc.BuildProgress:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case started = "S"
        case builder = "B"
    }
}
extension Unidoc.BuildProgress:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.started] = self.started
        bson[.builder] = self.builder
    }
}
extension Unidoc.BuildProgress:BSONDocumentDecodable
{
    public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            started: try bson[.started].decode(),
            builder: try bson[.builder].decode())
    }
}
