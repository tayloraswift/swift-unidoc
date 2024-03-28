import BSON
import MongoQL

extension Unidoc
{
    struct BuildMetadataDelta:Sendable
    {
        var progress:BuildProgress?
        var request:BuildRequest?
        var failure:BuildOutcome.Failure?

        init(progress:BuildProgress? = nil,
            request:BuildRequest? = nil,
            failure:BuildOutcome.Failure? = nil)
        {
            self.progress = progress
            self.request = request
            self.failure = failure
        }
    }
}
extension Unidoc.BuildMetadataDelta:Mongo.MasterCodingDelta
{
    typealias CodingKey = Unidoc.BuildMetadata.CodingKey
}
extension Unidoc.BuildMetadataDelta:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            progress: try bson[.progress]?.decode(),
            request: try bson[.request]?.decode(),
            failure: try bson[.failure]?.decode())
    }
}
