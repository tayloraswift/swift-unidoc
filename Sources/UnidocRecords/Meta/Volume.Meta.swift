import BSONDecoding
import BSONEncoding
import ModuleGraphs
import SemanticVersions
import SymbolGraphs
import Unidoc
import SHA1

extension Volume
{
    @frozen public
    struct Meta:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Edition

        public
        var dependencies:[Dependency]
        public
        var display:String?
        public
        var refname:String?
        public
        var commit:SHA1?

        public
        var symbol:VolumeIdentifier
        public
        var latest:Bool
        public
        var patch:PatchVersion?

        public
        var link:LinkDetails?
        /// Contains a tree of the cultures in this volume.
        public
        var tree:[Noun]

        public
        var api:MinorVersion

        @inlinable public
        init(id:Unidoc.Edition,
            dependencies:[Dependency] = [],
            display:String? = nil,
            refname:String? = nil,
            commit:SHA1? = nil,
            symbol:VolumeIdentifier,
            latest:Bool,
            patch:PatchVersion? = nil,
            link:LinkDetails? = nil,
            tree:[Noun] = [])
        {
            self.api = VolumeAPI.version

            self.id = id
            self.dependencies = dependencies
            self.display = display
            self.refname = refname
            self.commit = commit
            self.symbol = symbol
            self.latest = latest
            self.patch = patch
            self.link = link
            self.tree = tree
        }
    }
}
extension Volume.Meta
{
    @inlinable public
    var selector:Volume.Selector
    {
        .init(
            package: self.symbol.package,
            version: self.latest ? nil : self.symbol.version[...])
    }

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

        case dependencies = "K"
        case package = "P"
        case version = "V"
        case display = "D"
        /// This is currently copied verbatim from the symbol graph archive, but it is expected
        /// to match (and duplicate) the refname in the associated ``PackageEdition`` record.
        case refname = "G"
        case commit = "H"
        case patch = "S"
        case link = "N"
        case tree = "X"

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

        case api = "I"
    }
}
extension Volume.Meta:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.cell] = self.id.cell.package

        bson[.dependencies] = self.dependencies.isEmpty ? nil : self.dependencies
        bson[.package] = self.symbol.package
        bson[.version] = self.symbol.version

        bson[.display] = self.display
        bson[.refname] = self.refname
        bson[.commit] = self.commit

        bson[.latest] = self.latest ? true : nil
        bson[.patch] = self.patch
        bson[.link] = self.link
        bson[.tree] = Volume.NounTable.init(eliding: self.tree)

        bson[.planes_min] = self.planes.min

        bson[.planes_article] = self.planes.article
        bson[.planes_file] = self.planes.file

        bson[.planes_autogroup] = self.planes.autogroup
        bson[.planes_extension] = self.planes.extension
        bson[.planes_topic] = self.planes.topic

        bson[.planes_max] = self.planes.max

        bson[.api] = self.api
    }
}
extension Volume.Meta:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(),
            dependencies: try bson[.dependencies]?.decode() ?? [],
            display: try bson[.display]?.decode(),
            refname: try bson[.refname]?.decode(),
            commit: try bson[.commit]?.decode(),
            symbol: .init(
                package: try bson[.package].decode(),
                version: try bson[.version].decode()),
            latest: try bson[.latest]?.decode() ?? false,
            patch: try bson[.patch]?.decode(),
            link: try bson[.link]?.decode(),
            tree: try bson[.tree]?.decode(as: Volume.NounTable.self, with: \.rows) ?? [])

        self.api = try bson[.api]?.decode() ?? .v(0, 1)
    }
}
