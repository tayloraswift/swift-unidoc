import BSONDecoding
import ModuleGraphs
import MongoSchema
import SemanticVersions
import SymbolGraphs
import Unidoc
import UnidocAnalysis
import UnidocSelectors
import UnidocRecords

extension WideQuery.Output
{
    @frozen public
    struct Principal:Equatable, Sendable
    {
        public
        let matches:[Volume.Master]
        public
        let master:Volume.Master?
        public
        let groups:[Volume.Group]
        public
        let names:Volume.Names
        public
        let tree:Volume.TypeTree?

        @inlinable internal
        init(
            matches:[Volume.Master],
            master:Volume.Master?,
            groups:[Volume.Group],
            names:Volume.Names,
            tree:Volume.TypeTree?)
        {
            self.matches = matches
            self.master = master
            self.groups = groups
            self.names = names
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
        case groups = "G"
        case names = "Z"
        case tree = "T"

        // case _scalars = "scalars"
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
            groups: try bson[.groups].decode(),
            names: try bson[.names].decode(),
            tree: try bson[.tree]?.decode())
    }
}
