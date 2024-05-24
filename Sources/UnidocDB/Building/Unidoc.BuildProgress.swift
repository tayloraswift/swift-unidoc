import BSON
import MongoQL
import UnidocAPI
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct BuildProgress:Equatable, Sendable
    {
        public
        var started:BSON.Millisecond
        public
        var builder:Account
        public
        var request:BuildSelector
        public
        var stage:BuildStage

        @inlinable public
        init(started:BSON.Millisecond, builder:Account, request:BuildSelector, stage:BuildStage)
        {
            self.started = started
            self.builder = builder
            self.request = request
            self.stage = stage
        }
    }
}
extension Unidoc.BuildProgress:Mongo.MasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case started = "S"
        case builder = "b"
        case request = "R"
        case stage = "P"
    }
}
extension Unidoc.BuildProgress:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.started] = self.started
        bson[.builder] = self.builder
        bson[.request] = self.request
        bson[.stage] = self.stage
    }
}
extension Unidoc.BuildProgress:BSONDocumentDecodable
{
    public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            started: try bson[.started].decode(),
            builder: try bson[.builder].decode(),
            request: try bson[.request].decode(),
            stage: try bson[.stage].decode())
    }
}
