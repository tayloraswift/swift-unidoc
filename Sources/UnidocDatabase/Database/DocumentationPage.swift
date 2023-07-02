import BSONDecoding
import BSONEncoding
import ModuleGraphs
import SemanticVersions
import SymbolGraphs
import Unidoc

@frozen public
struct DocumentationPage:Equatable, Sendable
{
    public
    let id:Unidoc.Scalar

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

    @inlinable public
    init(id:Unidoc.Scalar,
        package:PackageIdentifier,
        version:String,
        recency:SemanticVersion?,
        matches:[Record.Master],
        master:Record.Master?)
    {
        self.id = id
        self.package = package
        self.version = version
        self.recency = recency
        self.matches = matches
        self.master = master
    }
}
extension DocumentationPage
{
    @frozen public
    enum CodingKeys:String
    {
        case id = "_id"

        case package = "P"
        case version = "V"
        case recency = "S"

        case matches = "A"
        case master = "M"
    }

    static
    subscript(key:CodingKeys) -> String
    {
        key.rawValue
    }
}
extension DocumentationPage:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(),
            package: try bson[.package].decode(),
            version: try bson[.version].decode(),
            recency: try bson[.recency]?.decode(),
            matches: try bson[.matches].decode(),
            master: try bson[.master]?.decode())
    }
}
