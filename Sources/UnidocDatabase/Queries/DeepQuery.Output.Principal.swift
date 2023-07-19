import BSONDecoding
import BSONEncoding
import ModuleGraphs
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
        let latest:Bool

        public
        let extensions:[Record.Extension]
        public
        let matches:[Record.Master]
        public
        let master:Record.Master?

        @inlinable internal
        init(
            package:PackageIdentifier,
            version:String,
            refname:String?,
            latest:Bool,
            extensions:[Record.Extension],
            matches:[Record.Master],
            master:Record.Master?)
        {
            self.package = package
            self.version = version
            self.refname = refname
            self.latest = latest

            self.extensions = extensions
            self.matches = matches
            self.master = master
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
            latest: self.latest)
    }
}
extension DeepQuery.Output.Principal
{
    @frozen public
    enum CodingKey:String, CaseIterable
    {
        case extensions = "e"
        case matches = "a"
        case master = "m"

        //  These keys come from ``Record.Zone.CodingKey``.
        //  TODO: find a way to hitch this to the actual definitions
        //  in ``Record.Zone.CodingKey``.
        case package = "P"
        case version = "V"
        case refname = "G"
        case latest = "L"
    }

    static
    subscript(key:CodingKey) -> BSON.Key { .init(key) }
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
            latest: try bson[.latest]?.decode() ?? false,
            extensions: try bson[.extensions].decode(),
            matches: try bson[.matches].decode(),
            master: try bson[.master]?.decode())
    }
}
