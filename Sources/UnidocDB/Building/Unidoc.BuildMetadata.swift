import BSON
import MongoQL
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct BuildMetadata:Identifiable, Sendable
    {
        public
        let id:Package

        public
        var progress:BuildProgress?
        public
        var request:BuildRequest?
        public
        var failure:BuildFailure?
        public
        var logs:[BuildLogType]

        @inlinable public
        init(id:Unidoc.Package,
            progress:Unidoc.BuildProgress? = nil,
            request:Unidoc.BuildRequest? = nil,
            failure:Unidoc.BuildFailure? = nil,
            logs:[BuildLogType] = [])
        {
            self.id = id
            self.progress = progress
            self.request = request
            self.failure = failure
            self.logs = logs
        }
    }
}
extension Unidoc.BuildMetadata:Mongo.MasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable, BSONDecodable
    {
        case id = "_id"
        case progress = "P"
        case request = "Q"
        case failure = "F"
        case logs = "L"
    }
}
extension Unidoc.BuildMetadata:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.progress] = self.progress
        bson[.request] = self.request
        bson[.failure] = self.failure
        bson[.logs] = self.logs.isEmpty ? nil : self.logs
    }
}
extension Unidoc.BuildMetadata:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(id: try bson[.id].decode(),
            progress: try bson[.progress]?.decode(),
            request: try bson[.request]?.decode(),
            failure: try bson[.failure]?.decode(),
            logs: try bson[.logs]?.decode() ?? [])
    }
}
