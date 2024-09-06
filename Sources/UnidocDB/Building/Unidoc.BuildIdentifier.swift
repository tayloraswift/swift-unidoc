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
        let date:UnixMillisecond

        @inlinable public
        init(edition:Unidoc.Edition, date:UnixMillisecond)
        {
            self.edition = edition
            self.date = date
        }
    }
}
extension Unidoc.BuildIdentifier:Mongo.MasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable, BSONDecodable
    {
        case edition = "e"
        case date = "T"
    }
}
extension Unidoc.BuildIdentifier:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.edition] = self.edition
        bson[.date] = self.date
    }
}
extension Unidoc.BuildIdentifier:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(edition: try bson[.edition].decode(), date: try bson[.date].decode())
    }
}
