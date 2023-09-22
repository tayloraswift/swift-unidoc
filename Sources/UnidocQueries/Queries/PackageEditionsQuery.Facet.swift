import BSONDecoding
import MongoQL
import UnidocDB

extension PackageEditionsQuery
{
    @frozen public
    struct Facet:Equatable, Sendable
    {
        public
        var edition:PackageEdition
        public
        var graphs:Graphs?

        @inlinable public
        init(edition:PackageEdition, graphs:Graphs? = nil)
        {
            self.edition = edition
            self.graphs = graphs
        }
    }
}
extension PackageEditionsQuery.Facet:MongoMasterCodingModel
{
    public
    enum CodingKey:String
    {
        case edition
        case graphs
    }
}
extension PackageEditionsQuery.Facet:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            edition: try bson[.edition].decode(),
            graphs: try bson[.graphs]?.decode())
    }
}
