import BSONDecoding
import ModuleGraphs
import MongoSchema
import SemanticVersions
import SymbolGraphs
import Unidoc
import UnidocDB
import UnidocAnalysis
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
        let master:Volume.Vertex?
        public
        let masterInLatest:Volume.Vertex?

        public
        let groups:[Volume.Group]

        public
        let names:Volume.Names
        public
        let namesOfLatest:Volume.Names?

        public
        let repo:PackageRepo?

        public
        let tree:Volume.TypeTree?

        @inlinable internal
        init(
            matches:[Volume.Vertex],
            master:Volume.Vertex?,
            masterInLatest:Volume.Vertex?,
            groups:[Volume.Group],
            names:Volume.Names,
            namesOfLatest:Volume.Names?,
            repo:PackageRepo?,
            tree:Volume.TypeTree?)
        {
            self.matches = matches

            self.master = master
            self.masterInLatest = masterInLatest

            self.groups = groups

            self.names = names
            self.namesOfLatest = namesOfLatest

            self.repo = repo
            self.tree = tree
        }
    }
}
extension WideQuery.Output.Principal:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, CaseIterable
    {
        case matches = "A"
        case master = "M"
        case masterInLatest = "L"
        case groups = "G"
        case names = "Z"
        case namesOfLatest = "R"
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
            master: try bson[.master]?.decode(),
            masterInLatest: try bson[.masterInLatest]?.decode(),
            groups: try bson[.groups].decode(),
            names: try bson[.names].decode(),
            namesOfLatest: try bson[.namesOfLatest]?.decode(),
            repo: try bson[.repo]?.decode(),
            tree: try bson[.tree]?.decode())
    }
}
