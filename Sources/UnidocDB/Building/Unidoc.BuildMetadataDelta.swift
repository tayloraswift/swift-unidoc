import BSON
import MongoQL

extension Unidoc
{
    struct BuildMetadataDelta:Sendable
    {
        var progress:BuildProgress?
        var selector:BuildSelector?
        var edition:Edition?
        var failure:BuildFailure?

        init(progress:BuildProgress? = nil,
            selector:BuildSelector? = nil,
            edition:Edition? = nil,
            failure:BuildFailure? = nil)
        {
            self.progress = progress
            self.selector = selector
            self.edition = edition
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
            selector: try bson[.selector]?.decode(),
            edition: try bson[.edition]?.decode(),
            failure: try bson[.failure]?.decode())
    }
}
