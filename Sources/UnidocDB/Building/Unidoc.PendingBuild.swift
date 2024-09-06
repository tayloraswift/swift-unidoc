import BSON
import MongoQL
import Symbols
import UnidocAPI
import UnidocRecords
import UnixTime

extension Unidoc
{
    @frozen public
    struct PendingBuild:Identifiable, Sendable
    {
        public
        let id:Edition

        public
        let enqueued:UnixMillisecond?
        public
        let launched:UnixMillisecond?

        public
        let assignee:Account?
        public
        var stage:BuildStage?

        /// This is used to identify the build when it completes.
        public
        let date:UnixMillisecond
        /// Used for display purposes only.
        public
        let name:Symbol.PackageAtRef

        @inlinable public
        init(id:Edition,
            enqueued:UnixMillisecond?,
            launched:UnixMillisecond?,
            assignee:Account?,
            stage:BuildStage?,
            date:UnixMillisecond,
            name:Symbol.PackageAtRef)
        {
            self.id = id
            self.enqueued = enqueued
            self.launched = launched
            self.assignee = assignee
            self.stage = stage
            self.date = date
            self.name = name
        }
    }
}
extension Unidoc.PendingBuild:Mongo.MasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable, BSONDecodable
    {
        case id = "_id"
        case enqueued = "Q"
        case launched = "L"
        case assignee = "A"
        case stage = "S"
        case date = "T"
        case name = "N"

        case package = "p"
    }
}
extension Unidoc.PendingBuild:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.enqueued] = self.enqueued
        bson[.launched] = self.launched
        bson[.assignee] = self.assignee
        bson[.stage] = self.stage
        bson[.date] = self.date
        bson[.name] = self.name

        bson[.package] = self.id.package
    }
}
extension Unidoc.PendingBuild:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(id: try bson[.id].decode(),
            enqueued: try bson[.enqueued]?.decode(),
            launched: try bson[.launched]?.decode(),
            assignee: try bson[.assignee]?.decode(),
            stage: try bson[.stage]?.decode(),
            date: try bson[.date].decode(),
            name: try bson[.name].decode())
    }
}
