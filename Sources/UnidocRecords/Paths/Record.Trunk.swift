import BSONDecoding
import BSONEncoding
import ModuleGraphs
import SymbolGraphs

extension Record
{
    @frozen public
    struct Trunk:Equatable, Hashable, Sendable
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

        @inlinable public
        init(package:PackageIdentifier,
            version:String,
            refname:String?,
            display:String?,
            github:String?,
            latest:Bool)
        {
            self.package = package
            self.version = version
            self.refname = refname
            self.display = display
            self.github = github
            self.latest = latest
        }
    }
}
extension Record.Trunk
{
    @inlinable public static
    var keys:[CodingKey]
    {
        [
            .package,
            .version,
            .refname,
            .display,
            .github,
            .latest,
        ]
    }
}
extension Record.Trunk:BSONDocumentDecodable
{
    public
    typealias CodingKey = Record.Zone.CodingKey

    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            package: try bson[.package].decode(),
            version: try bson[.version].decode(),
            refname: try bson[.refname]?.decode(),
            display: try bson[.display]?.decode(),
            github: try bson[.github]?.decode(),
            latest: try bson[.latest]?.decode() ?? false)
    }
}
