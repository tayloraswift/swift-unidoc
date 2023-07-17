import BSONDecoding
import BSONEncoding
import ModuleGraphs
import SemanticVersions
import SymbolGraphs
import Unidoc

extension Record
{
    @frozen public
    struct Zone:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Zone

        public
        let package:PackageIdentifier
        /// A string identifying the package version within the database.
        /// This string is `$anonymous` if this zone was generated from an
        /// unversioned snapshot.
        /// If the ``refname`` is a `v`-prefixed semantic version, this
        /// string encodes the version without the `v` prefix.
        public
        let version:String
        public
        let refname:String?

        public
        let patch:PatchVersion?

        @inlinable public
        init(id:Unidoc.Zone,
            package:PackageIdentifier,
            version:String,
            refname:String?,
            patch:PatchVersion?)
        {
            self.id = id
            self.package = package
            self.version = version
            self.refname = refname
            self.patch = patch
        }
    }
}
extension Record.Zone
{
    public
    init(_ zone:Unidoc.Zone, package:PackageIdentifier, version:AnyVersion?, refname:String?)
    {
        self.init(id: zone,
            package: package,
            version: version?.description ?? "$anonymous",
            refname: refname,
            patch: version?.stable?.release)
    }

    @inlinable public
    var planes:Planes { .init(zone: self.id) }

    @inlinable public
    var names:Names
    {
        .init(package: self.package, version: self.version, refname: self.refname)
    }
}
extension Record.Zone
{
    @frozen public
    enum CodingKey:String
    {
        case id = "_id"

        case package = "P"
        case version = "V"
        case refname = "G"
        case patch = "S"

        case planes_min = "L"

        case planes_article = "A"
        case planes_extension = "E"
        case planes_file = "F"

        case planes_max = "U"
    }

    @inlinable public static
    subscript(key:CodingKey) -> BSON.Key { .init(key) }
}
extension Record.Zone:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.package] = self.package
        bson[.version] = self.version
        bson[.refname] = self.refname
        bson[.patch] = self.patch

        bson[.planes_min] = self.planes.min

        bson[.planes_article] = self.planes.article
        bson[.planes_extension] = self.planes.extension
        bson[.planes_file] = self.planes.file

        bson[.planes_max] = self.planes.max
    }
}
extension Record.Zone:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(),
            package: try bson[.package].decode(),
            version: try bson[.version].decode(),
            refname: try bson[.refname]?.decode(),
            patch: try bson[.patch]?.decode())
    }
}
