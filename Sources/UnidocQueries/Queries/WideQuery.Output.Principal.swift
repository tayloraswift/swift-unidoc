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
        let matches:[Record.Master]
        public
        let master:Record.Master?
        public
        let groups:[Record.Group]
        public
        let tree:Record.NounTree?
        public
        let zone:Record.Zone


        @inlinable internal
        init(
            matches:[Record.Master],
            master:Record.Master?,
            groups:[Record.Group],
            tree:Record.NounTree?,
            zone:Record.Zone)
        {
            self.matches = matches
            self.master = master
            self.groups = groups
            self.tree = tree
            self.zone = zone
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
        case tree = "T"
        case zone = "Z"

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
            tree: try bson[.tree]?.decode(),
            zone: try bson[.zone].decode())
    }
}
