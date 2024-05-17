import BSON
import MongoQL
import SemanticVersions
import SymbolGraphs
import Unidoc
import UnidocDB
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct PrincipalOutput:Sendable
    {
        public
        let matches:[AnyVertex]
        public
        let vertex:AnyVertex?
        public
        let groups:[AnyGroup]
        public
        let volume:VolumeMetadata
        public
        let volumeOfLatest:VolumeMetadata?

        public
        let tree:TypeTree?

        @inlinable internal
        init(
            matches:[AnyVertex],
            vertex:AnyVertex?,
            groups:[AnyGroup],
            volume:VolumeMetadata,
            volumeOfLatest:VolumeMetadata?,
            tree:TypeTree?)
        {
            self.matches = matches
            self.vertex = vertex
            self.groups = groups
            self.volume = volume
            self.volumeOfLatest = volumeOfLatest

            self.tree = tree
        }
    }
}
extension Unidoc.PrincipalOutput:Mongo.MasterCodingModel
{
    @frozen public
    enum CodingKey:String, CaseIterable, Sendable
    {
        case matches = "A"
        case vertex = "M"
        case groups = "G"
        case volume = "Z"
        case volumeOfLatest = "R"
        case tree = "T"
    }
}
extension Unidoc.PrincipalOutput:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            matches: try bson[.matches].decode(),
            vertex: try bson[.vertex]?.decode(),
            groups: try bson[.groups].decode(),
            volume: try bson[.volume].decode(),
            volumeOfLatest: try bson[.volumeOfLatest]?.decode(),
            tree: try bson[.tree]?.decode())
    }
}
