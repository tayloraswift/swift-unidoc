import BSON
import MongoQL
import UnidocAPI
import UnidocRecords
import UnixTime

extension Unidoc
{
    @frozen public
    struct CompleteBuild:Sendable
    {
        public
        let edition:Edition

        public
        let launched:UnixMillisecond
        public
        let finished:UnixMillisecond

        public
        var failure:BuildFailure?
        public
        var logs:[BuildLogType]

        @inlinable public
        init(edition:Edition,
            launched:UnixMillisecond,
            finished:UnixMillisecond,
            failure:BuildFailure?,
            logs:[BuildLogType])
        {
            self.edition = edition
            self.launched = launched
            self.finished = finished
            self.failure = failure
            self.logs = logs
        }
    }
}
extension Unidoc.CompleteBuild
{
    @inlinable public
    init(id:Unidoc.BuildIdentifier,
        finished:UnixMillisecond,
        failure:Unidoc.BuildFailure?,
        logs:[Unidoc.BuildLogType])
    {
        self.init(edition: id.edition,
            launched: id.instant,
            finished: finished,
            failure: failure,
            logs: logs)
    }
}
extension Unidoc.CompleteBuild:Identifiable
{
    @inlinable public
    var id:Unidoc.BuildIdentifier { .init(edition: self.edition, instant: self.launched) }
}
extension Unidoc.CompleteBuild:Mongo.MasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable, BSONDecodable
    {
        case id = "_id"
        case finished = "F"
        case failure = "E"
        case logs = "O"

        case package = "p"
    }
}
extension Unidoc.CompleteBuild:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.finished] = self.finished
        bson[.failure] = self.failure
        bson[.logs] = self.logs.isEmpty ? nil : self.logs

        bson[.package] = self.id.edition.package
    }
}
extension Unidoc.CompleteBuild:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(id: try bson[.id].decode(),
            finished: try bson[.finished].decode(),
            failure: try bson[.failure]?.decode(),
            logs: try bson[.logs]?.decode() ?? [])
    }
}
