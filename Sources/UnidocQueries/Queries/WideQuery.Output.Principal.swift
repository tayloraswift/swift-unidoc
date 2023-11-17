import BSONDecoding
import ModuleGraphs
import MongoSchema
import SemanticVersions
import SymbolGraphs
import Unidoc
import UnidocDB
import UnidocSelectors
import UnidocRecords

extension WideQuery.Output
{
    @frozen public
    struct Principal:Equatable, Sendable
    {
        public
        let matches:[Volume.Vertex]

        public
        let vertex:Volume.Vertex?
        public
        let vertexInLatest:Volume.Vertex?

        public
        let groups:[Volume.Group]

        public
        let volume:Volume.Meta
        public
        let volumeOfLatest:Volume.Meta?

        public
        let repo:Realm.Repo?

        public
        let tree:Volume.TypeTree?

        @inlinable internal
        init(
            matches:[Volume.Vertex],
            vertex:Volume.Vertex?,
            vertexInLatest:Volume.Vertex?,
            groups:[Volume.Group],
            volume:Volume.Meta,
            volumeOfLatest:Volume.Meta?,
            repo:Realm.Repo?,
            tree:Volume.TypeTree?)
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
extension WideQuery.Output.Principal:MongoMasterCodingModel
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
extension WideQuery.Output.Principal:BSONDocumentDecodable
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
