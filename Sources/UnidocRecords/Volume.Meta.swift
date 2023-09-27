import BSONDecoding
import BSONEncoding
import ModuleGraphs
import SemanticVersions
import SymbolGraphs
import Unidoc

extension Volume
{
    @available(*, deprecated, renamed: "Meta")
    public typealias Names = Volume.Meta
}
extension Volume
{
    @frozen public
    struct Meta:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Zone

        public
        var display:String?
        public
        var refname:String?

        @available(*, unavailable)
        public
        var origin:Origin? { nil }

        public
        var symbol:VolumeIdentifier
        public
        var latest:Bool

        public
        var patch:PatchVersion?

        @inlinable public
        init(id:Unidoc.Zone,
            display:String?,
            refname:String?,
            symbol:VolumeIdentifier,
            latest:Bool,
            patch:PatchVersion?)
        {
            self.id = id
            self.display = display
            self.refname = refname
            self.symbol = symbol
            self.latest = latest
            self.patch = patch
        }
    }
}
extension Volume.Meta
{
    @available(*, deprecated)
    @inlinable public
    var package:PackageIdentifier { self.symbol.package }

    @available(*, deprecated)
    @inlinable public
    var version:String { self.symbol.version }

    @inlinable public
    var planes:Planes { .init(zone: self.id) }
}
extension Volume.Meta
{
    @frozen public
    enum CodingKey:String, Equatable, Hashable, Sendable
    {
        case id = "_id"

        case cell = "O"

        case package = "P"
        case version = "V"
        case display = "D"
        /// This is currently copied verbatim from the symbol graph archive, but it is expected
        /// to match (and duplicate) the refname in the associated ``PackageEdition`` record.
        case refname = "G"

        @available(*, unavailable)
        case origin = "H"

        case patch = "S"

        case planes_min = "C"

        case planes_article = "A"
        case planes_file = "F"

        case planes_autogroup = "U"
        case planes_extension = "E"
        case planes_topic = "T"

        case planes_max = "Z"

        /// Indicates if this zone contains records from the latest release
        /// version of its package. This flag is non-authoritative and only
        /// exists as a query optimization. It is computed and aligned within
        /// the database according to the value of the ``patch`` field.
        case latest = "L"

        /// The list of non-computed fields in this scheme. This is used as a
        /// projection filter to avoid returning computed fields.
        @inlinable public static
        var independent:[Self]
        {
            [
                .id,
                .package,
                .version,
                .refname,
                .display,
                .patch,

                .latest,
            ]
        }
    }
}
extension Volume.Meta:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.cell] = self.id.cell.package

        bson[.package] = self.symbol.package
        bson[.version] = self.symbol.version

        bson[.display] = self.display
        bson[.refname] = self.refname

        bson[.latest] = self.latest ? true : nil
        bson[.patch] = self.patch

        bson[.planes_min] = self.planes.min

        bson[.planes_article] = self.planes.article
        bson[.planes_file] = self.planes.file

        bson[.planes_autogroup] = self.planes.autogroup
        bson[.planes_extension] = self.planes.extension
        bson[.planes_topic] = self.planes.topic

        bson[.planes_max] = self.planes.max
    }
}
extension Volume.Meta:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(),
            display: try bson[.display]?.decode(),
            refname: try bson[.refname]?.decode(),
            symbol: .init(
                package: try bson[.package].decode(),
                version: try bson[.version].decode()),
            latest: try bson[.latest]?.decode() ?? false,
            patch: try bson[.patch]?.decode())
    }
}
