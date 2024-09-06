import BSON
import MongoQL
import UnixTime

extension Unidoc
{
    struct PendingBuildDelta:Sendable
    {
        var enqueued:UnixMillisecond?
        var launched:UnixMillisecond?
        var stage:BuildStage?

        init(enqueued:UnixMillisecond?, launched:UnixMillisecond?, stage:BuildStage?)
        {
            self.enqueued = enqueued
            self.launched = launched
            self.stage = stage
        }
    }
}
extension Unidoc.PendingBuildDelta:Mongo.MasterCodingDelta
{
    typealias Model = Unidoc.PendingBuild
}
extension Unidoc.PendingBuildDelta:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<Unidoc.PendingBuild.CodingKey>) throws
    {
        self.init(
            enqueued: try bson[.enqueued]?.decode(),
            launched: try bson[.launched]?.decode(),
            stage: try bson[.stage]?.decode())
    }
}
