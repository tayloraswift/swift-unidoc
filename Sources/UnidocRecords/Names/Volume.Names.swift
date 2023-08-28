import BSONDecoding
import BSONEncoding
import ModuleGraphs
import SemanticVersions
import SymbolGraphs
import Unidoc

extension Volume
{
    @available(*, deprecated, renamed: "Names")
    public typealias Zone = Names
}
extension Volume
{
    @frozen public
    struct Names:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Zone

        public
        var refname:String?
        public
        var display:String?
        public
        var github:String?

        public
        var volume:VolumeIdentifier
        public
        var latest:Bool

        public
        var patch:PatchVersion?

        @inlinable public
        init(id:Unidoc.Zone,
            refname:String?,
            display:String?,
            github:String?,
            volume:VolumeIdentifier,
            latest:Bool,
            patch:PatchVersion?)
        {
            self.id = id
            self.refname = refname
            self.display = display
            self.github = github
            self.volume = volume
            self.latest = latest
            self.patch = patch
        }
    }
}
extension Volume.Names
{
    @inlinable public
    var package:PackageIdentifier { self.volume.package }

    @inlinable public
    var version:String { self.volume.version }

    @inlinable public
    var planes:Planes { .init(zone: self.id) }
}
extension Volume.Names
{
    @frozen public
    enum CodingKey:String, Equatable, Hashable, Sendable
    {
        case id = "_id"

        case package = "P"
        case version = "V"
        case refname = "G"
        case display = "D"
        case github = "H"
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
                .github,
                .patch,

                .latest,
            ]
        }
    }
}
extension Volume.Names:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.package] = self.volume.package
        bson[.version] = self.volume.version
        bson[.refname] = self.refname

        bson[.display] = self.display
        bson[.github] = self.github

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
extension Volume.Names:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(),
            refname: try bson[.refname]?.decode(),
            display: try bson[.display]?.decode(),
            github: try bson[.github]?.decode(),
            volume: .init(
                package: try bson[.package].decode(),
                version: try bson[.version].decode()),
            latest: try bson[.latest]?.decode() ?? false,
            patch: try bson[.patch]?.decode())
    }
}
