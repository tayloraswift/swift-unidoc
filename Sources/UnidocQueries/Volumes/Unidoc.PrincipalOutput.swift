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
        let matches:[Vertex]

        public
        let vertex:Vertex?
        public
        let vertexInLatest:Vertex?

        public
        let groups:[Group]

        public
        let volume:VolumeMetadata
        public
        let volumeOfLatest:VolumeMetadata?

        public
        let repo:PackageRepo?

        public
        let tree:TypeTree?

        @inlinable internal
        init(
            matches:[Vertex],
            vertex:Vertex?,
            vertexInLatest:Vertex?,
            groups:[Group],
            volume:VolumeMetadata,
            volumeOfLatest:VolumeMetadata?,
            repo:PackageRepo?,
            tree:TypeTree?)
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
