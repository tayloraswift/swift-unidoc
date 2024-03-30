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
        var request:BuildRequest
        public
        var builder:Account

        @inlinable public
        init(started:BSON.Millisecond, request:BuildRequest, builder:Account)
        {
            self.started = started
            self.request = request
            self.builder = builder
        }
    }
}
extension Unidoc.BuildProgress:Mongo.MasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case started = "S"
        case request = "R"
        case builder = "b"
    }
}
extension Unidoc.BuildProgress:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.started] = self.started
        bson[.request] = self.request
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
            request: try bson[.request].decode(),
            builder: try bson[.builder].decode())
    }
}
