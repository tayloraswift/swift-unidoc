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
        /// This is used to identify the build when it completes.
        public
        let run:UnixMillisecond

        /// Build priority. Lower values are higher priority.
        public
        let priority:Int32
        public
        let enqueued:UnixMillisecond?
        public
        let launched:UnixMillisecond?

        public
        let assignee:Account?
        public
        var stage:BuildStage?

        /// Used for display purposes only.
        public
        let name:Symbol.PackageAtRef


        @inlinable public
        init(id:Edition,
            run:UnixMillisecond,
            priority:Int32,
            enqueued:UnixMillisecond?,
            launched:UnixMillisecond?,
            assignee:Account?,
            stage:BuildStage?,
            name:Symbol.PackageAtRef)
        {
            self.id = id
            self.run = run
            self.priority = priority
            self.enqueued = enqueued
            self.launched = launched
            self.assignee = assignee
            self.stage = stage
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
        case run = "T"
        case priority = "P"
        case enqueued = "Q"
        case launched = "L"
        case assignee = "A"
        case stage = "S"
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
        bson[.run] = self.run
        bson[.priority] = self.priority
        bson[.enqueued] = self.enqueued
        bson[.launched] = self.launched
        bson[.assignee] = self.assignee
        bson[.stage] = self.stage
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
            run: try bson[.run].decode(),
            priority: try bson[.priority].decode(),
            enqueued: try bson[.enqueued]?.decode(),
            launched: try bson[.launched]?.decode(),
            assignee: try bson[.assignee]?.decode(),
            stage: try bson[.stage]?.decode(),
            name: try bson[.name].decode())
    }
}
