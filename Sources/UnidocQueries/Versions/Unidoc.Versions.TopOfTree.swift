import BSON
import MongoDB
import UnidocRecords
import UnidocAPI

extension Unidoc.VersionsQuery
{
    @available(*, deprecated)
    public
    typealias Tagless = Unidoc.Versions.TopOfTree
}
extension Unidoc.Versions
{
    @frozen public
    struct TopOfTree:Equatable, Sendable
    {
        public
        var volume:Unidoc.VolumeMetadata?
        public
        var graph:Graph

        @inlinable public
        init(volume:Unidoc.VolumeMetadata?, graph:Graph)
        {
            self.volume = volume
            self.graph = graph
        }
    }
}
extension Unidoc.Versions.TopOfTree:Mongo.MasterCodingModel
{
    public
    typealias CodingKey = Unidoc.Versions.Tag.CodingKey
}
extension Unidoc.Versions.TopOfTree:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(volume: try bson[.volume]?.decode(), graph: try bson[.graph].decode())
    }
}
