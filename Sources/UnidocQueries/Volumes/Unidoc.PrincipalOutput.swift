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
    struct PrincipalOutput:Equatable, Sendable
    {
        public
        let matches:[Unidoc.Vertex]

        public
        let vertex:Unidoc.Vertex?
        public
        let vertexInLatest:Unidoc.Vertex?

        public
        let groups:[Unidoc.Group]

        public
        let volume:Unidoc.VolumeMetadata
        public
        let volumeOfLatest:Unidoc.VolumeMetadata?

        public
        let repo:PackageMetadata.Repo?

        public
        let tree:Unidoc.TypeTree?

        @inlinable internal
        init(
            matches:[Unidoc.Vertex],
            vertex:Unidoc.Vertex?,
            vertexInLatest:Unidoc.Vertex?,
            groups:[Unidoc.Group],
            volume:Unidoc.VolumeMetadata,
            volumeOfLatest:Unidoc.VolumeMetadata?,
            repo:PackageMetadata.Repo?,
            tree:Unidoc.TypeTree?)
        {
            self.matches = matches

            self.vertex = vertex
            self.vertexInLatest = vertexInLatest

            self.groups = groups

            self.volume = volume
            self.volumeOfLatest = volumeOfLatest

            self.repo = repo
            self.tree = tree
        }
    }
}
extension Unidoc.PrincipalOutput:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, CaseIterable, Sendable
    {
        case matches = "A"
        case vertex = "M"
        case vertexInLatest = "L"
        case groups = "G"
        case volume = "Z"
        case volumeOfLatest = "R"
        case repo = "O"
        case tree = "T"
    }
}
extension Unidoc.PrincipalOutput:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            matches: try bson[.matches].decode(),
            vertex: try bson[.vertex]?.decode(),
            vertexInLatest: try bson[.vertexInLatest]?.decode(),
            groups: try bson[.groups].decode(),
            volume: try bson[.volume].decode(),
            volumeOfLatest: try bson[.volumeOfLatest]?.decode(),
            repo: try bson[.repo]?.decode(),
            tree: try bson[.tree]?.decode())
    }
}
