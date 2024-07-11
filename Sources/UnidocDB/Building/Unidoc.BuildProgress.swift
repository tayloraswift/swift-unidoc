import BSON
import MongoQL
import UnidocAPI
import UnidocRecords
import UnixTime

extension Unidoc
{
    @frozen public
    struct BuildProgress:Equatable, Sendable
    {
        public
        var started:UnixMillisecond
        public
        var builder:Account
        public
        var request:BuildBehavior
        public
        var stage:BuildStage

        @inlinable public
        init(started:UnixMillisecond, builder:Account, request:BuildBehavior, stage:BuildStage)
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
