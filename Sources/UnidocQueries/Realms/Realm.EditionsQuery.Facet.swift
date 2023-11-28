import BSONDecoding
import MongoQL
import UnidocDB
import UnidocRecords

extension Realm.EditionsQuery
{
    @frozen public
    struct Facet:Equatable, Sendable
    {
        public
        var edition:Realm.Edition
        public
        var graphs:Graphs?
        public
        var volume:Volume.Meta?

        @inlinable public
        init(edition:Realm.Edition, graphs:Graphs? = nil, volume:Volume.Meta? = nil)
        {
            self.edition = edition
            self.graphs = graphs
            self.volume = volume
        }
    }
}
extension Realm.EditionsQuery.Facet:MongoMasterCodingModel
{
    public
    enum CodingKey:String, Sendable
    {
        case edition
        case graphs
        case volume
    }
}
extension Realm.EditionsQuery.Facet:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            edition: try bson[.edition].decode(),
            graphs: try bson[.graphs]?.decode(),
            volume: try bson[.volume]?.decode())
    }
}
