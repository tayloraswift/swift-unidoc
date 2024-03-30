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

        @inlinable public
        init(id:Unidoc.Package,
            progress:Unidoc.BuildProgress? = nil,
            request:Unidoc.BuildRequest? = nil,
            failure:Unidoc.BuildFailure? = nil)
        {
            self.id = id
            self.progress = progress
            self.request = request
            self.failure = failure
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
            failure: try bson[.failure]?.decode())
    }
}
