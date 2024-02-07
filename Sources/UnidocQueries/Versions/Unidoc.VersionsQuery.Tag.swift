import BSON
import MongoQL
import UnidocDB
import UnidocRecords

extension Unidoc.VersionsQuery
{
    @frozen public
    struct Tag:Equatable, Sendable
    {
        public
        var edition:Unidoc.EditionMetadata

        public
        var volume:Unidoc.VolumeMetadata?
        public
        var graph:Graph?

        @inlinable public
        init(edition:Unidoc.EditionMetadata,
            volume:Unidoc.VolumeMetadata?,
            graph:Graph?)
        {
            self.edition = edition
            self.volume = volume
            self.graph = graph
        }
    }
}
extension Unidoc.VersionsQuery.Tag:MongoMasterCodingModel
{
    public
    enum CodingKey:String, Sendable
    {
        case edition
        case volume
        case graph
    }
}
extension Unidoc.VersionsQuery.Tag:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(edition: try bson[.edition].decode(),
            volume: try bson[.volume]?.decode(),
            graph: try bson[.graph]?.decode())
    }
}
