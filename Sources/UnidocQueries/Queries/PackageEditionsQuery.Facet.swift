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
        /// True for a release, false for a prerelease, nil for a branch or an irregular tag.
        public
        var release:Bool?
        public
        var graphs:Graphs?

        @inlinable public
        init(edition:PackageEdition, release:Bool? = nil, graphs:Graphs? = nil)
        {
            self.edition = edition
            self.release = release
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
        case release
        case graphs
    }
}
extension PackageEditionsQuery.Facet:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(edition: try bson[.edition].decode(),
            release: try bson[.release]?.decode(),
            graphs: try bson[.graphs]?.decode())
    }
}
