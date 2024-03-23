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
        var edition:Edition
        public
        var builder:Account

        @inlinable public
        init(started:BSON.Millisecond, edition:Edition, builder:Account)
        {
            self.started = started
            self.edition = edition
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
        case edition = "e"
        case builder = "b"
    }
}
extension Unidoc.BuildProgress:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.started] = self.started
        bson[.edition] = self.edition
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
            edition: try bson[.edition].decode(),
            builder: try bson[.builder].decode())
    }
}
