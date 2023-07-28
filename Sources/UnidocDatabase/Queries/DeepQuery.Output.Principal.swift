import BSONDecoding
import BSONEncoding
import ModuleGraphs
import MongoSchema
import SemanticVersions
import SymbolGraphs
import Unidoc
import UnidocRecords

extension DeepQuery.Output
{
    @frozen public
    struct Principal:Equatable, Sendable
    {
        public
        let package:PackageIdentifier
        public
        let version:String
        public
        let refname:String?
        public
        let display:String?
        public
        let github:String?
        public
        let latest:Bool

        public
        let matches:[Record.Master]
        public
        let master:Record.Master?
        public
        let groups:[Record.Group]

        @inlinable internal
        init(
            package:PackageIdentifier,
            version:String,
            refname:String?,
            display:String?,
            github:String?,
            latest:Bool,
            matches:[Record.Master],
            master:Record.Master?,
            groups:[Record.Group])
        {
            self.package = package
            self.version = version
            self.refname = refname
            self.display = display
            self.github = github
            self.latest = latest

            self.matches = matches
            self.master = master
            self.groups = groups
        }
    }
}
extension DeepQuery.Output.Principal
{
    @inlinable public
    var zone:Record.Zone.Names
    {
        .init(package: self.package,
            version: self.version,
            refname: self.refname,
            display: self.display,
            github: self.github,
            latest: self.latest)
    }
}
//  TODO: this is a pretty fishy conformance... we should not have two master models for
//  the same document type.
extension DeepQuery.Output.Principal:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, CaseIterable
    {
        case matches = "a"
        case master = "m"
        case groups = "g"

        //  These keys come from ``Record.Zone.CodingKey``.
        //  TODO: find a way to hitch this to the actual definitions
        //  in ``Record.Zone.CodingKey``.
        case package = "P"
        case version = "V"
        case refname = "G"
        case display = "D"
        case github = "H"
        case latest = "L"

        // case _scalars = "scalars"
    }
}
extension DeepQuery.Output.Principal:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            package: try bson[.package].decode(),
            version: try bson[.version].decode(),
            refname: try bson[.refname]?.decode(),
            display: try bson[.display]?.decode(),
            github: try bson[.github]?.decode(),
            latest: try bson[.latest]?.decode() ?? false,
            matches: try bson[.matches].decode(),
            master: try bson[.master]?.decode(),
            groups: try bson[.groups].decode())
    }
}
