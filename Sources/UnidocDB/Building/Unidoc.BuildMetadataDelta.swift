import BSON
import MongoQL

extension Unidoc
{
    struct BuildMetadataDelta:Sendable
    {
        var progress:BuildProgress?
        var behavior:BuildBehavior?
        var edition:Edition?
        var failure:BuildFailure?

        init(progress:BuildProgress? = nil,
            behavior:BuildBehavior? = nil,
            edition:Edition? = nil,
            failure:BuildFailure? = nil)
        {
            self.progress = progress
            self.behavior = behavior
            self.edition = edition
            self.failure = failure
        }
    }
}
extension Unidoc.BuildMetadataDelta:Mongo.MasterCodingDelta
{
    typealias Model = Unidoc.BuildMetadata
}
extension Unidoc.BuildMetadataDelta:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<Unidoc.BuildMetadata.CodingKey>) throws
    {
        self.init(
            progress: try bson[.progress]?.decode(),
            behavior: try bson[.behavior]?.decode(),
            edition: try bson[.edition]?.decode(),
            failure: try bson[.failure]?.decode())
    }
}
