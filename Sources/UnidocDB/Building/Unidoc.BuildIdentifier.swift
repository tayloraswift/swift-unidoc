import BSON
import MongoQL
import UnidocRecords
import UnixTime

extension Unidoc
{
    @frozen public
    struct BuildIdentifier:Equatable, Hashable, Sendable
    {
        public
        let edition:Unidoc.Edition
        public
        let instant:UnixMillisecond

        @inlinable public
        init(edition:Unidoc.Edition, instant:UnixMillisecond)
        {
            self.edition = edition
            self.instant = instant
        }
    }
}
extension Unidoc.BuildIdentifier:Mongo.MasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable, BSONDecodable
    {
        case edition = "e"
        case instant = "T"
    }
}
extension Unidoc.BuildIdentifier:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.edition] = self.edition
        bson[.instant] = self.instant
    }
}
extension Unidoc.BuildIdentifier:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(edition: try bson[.edition].decode(), instant: try bson[.instant].decode())
    }
}
