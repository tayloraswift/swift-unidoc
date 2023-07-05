import BSONDecoding
import BSONEncoding
import ModuleGraphs
import SemanticVersions
import SymbolGraphs
import Unidoc

extension Docpage
{
    @frozen public
    struct Principal:Equatable, Sendable
    {
        public
        let zone:Unidoc.Zone

        public
        let package:PackageIdentifier
        public
        let version:String

        public
        let recency:SemanticVersion?

        public
        let matches:[Record.Master]
        public
        let master:Record.Master?

        public
        let extensions:[Record.Extension]

        @inlinable public
        init(zone:Unidoc.Zone,
            package:PackageIdentifier,
            version:String,
            recency:SemanticVersion?,
            matches:[Record.Master],
            master:Record.Master?,
            extensions:[Record.Extension])
        {
            self.zone = zone
            self.package = package
            self.version = version
            self.recency = recency
            self.matches = matches
            self.master = master
            self.extensions = extensions
        }
    }
}
extension Docpage.Principal
{
    @frozen public
    enum CodingKeys:String
    {
        //  The zone field originates from ``Record.Zone.CodingKeys.id``.
        case zone = "_id"

        case package = "P"
        case version = "V"
        case recency = "S"

        case matches = "A"
        case master = "M"
        case extensions = "E"
    }

    @inlinable public static
    subscript(key:CodingKeys) -> BSON.Key { .init(key) }
}
extension Docpage.Principal:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(zone: try bson[.zone].decode(),
            package: try bson[.package].decode(),
            version: try bson[.version].decode(),
            recency: try bson[.recency]?.decode(),
            matches: try bson[.matches].decode(),
            master: try bson[.master]?.decode(),
            extensions: try bson[.extensions].decode())
    }
}
