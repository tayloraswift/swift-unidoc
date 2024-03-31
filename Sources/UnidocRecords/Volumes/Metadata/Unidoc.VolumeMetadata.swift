import BSON
import SemanticVersions
import SHA1
import SymbolGraphs
import Symbols
import Unidoc

extension Unidoc
{
    @frozen public
    struct VolumeMetadata:Identifiable, Equatable, Sendable
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
        var symbol:Symbol.Edition
        public
        var latest:Bool
        public
        var realm:Unidoc.Realm?
        public
        var patch:PatchVersion?

        public
        var products:[Noun]
        /// Contains a tree of the cultures in this volume.
        public
        var cultures:[Noun]

        public
        var abi:MinorVersion

        @inlinable public
        init(id:Unidoc.Edition,
            dependencies:[Dependency] = [],
            display:String? = nil,
            refname:String? = nil,
            symbol:Symbol.Edition,
            latest:Bool,
            realm:Unidoc.Realm?,
            patch:PatchVersion? = nil,
            products:[Noun] = [],
            cultures:[Noun] = [])
        {
            self.abi = VolumeABI.version

            self.id = id
            self.dependencies = dependencies
            self.display = display
            self.refname = refname
            self.symbol = symbol
            self.latest = latest
            self.realm = realm
            self.patch = patch
            self.products = products
            self.cultures = cultures
        }
    }
}
extension Unidoc.VolumeMetadata
{
    @inlinable public
    var selector:Unidoc.VolumeSelector
    {
        .init(
            package: self.symbol.package,
            version: self.latest ? nil : self.symbol.version[...])
    }

    @available(*, deprecated)
    @inlinable public
    var package:Symbol.Package { self.symbol.package }

    @available(*, deprecated)
    @inlinable public
    var version:String { self.symbol.version }
}
extension Unidoc.VolumeMetadata
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
        /// to match (and duplicate) the refname in the associated ``Unidoc.EditionMetadata``
        /// record.
        case refname = "G"

        @available(*, unavailable)
        case commit = "H"

        case patch = "S"

        case products = "W"
        case cultures = "X"

        @available(*, unavailable)
        case min_article = "A"
        @available(*, unavailable)
        case min_file = "F"
        @available(*, unavailable)
        case min_polygon = "U"
        @available(*, unavailable)
        case min_extension = "E"
        @available(*, unavailable)
        case min_topic = "T"

        case min = "C"
        case max = "Z"

        /// Indicates if this zone contains records from the latest release version of its
        /// package. It is computed and aligned within the database according to the value of
        /// the ``patch`` field.
        ///
        /// This field currently only exists in order to compute the volume ``selector``.
        case latest = "L"
        case realm = "R"

        case abi = "I"
    }
}
extension Unidoc.VolumeMetadata:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.cell] = self.id.package

        bson[.dependencies] = self.dependencies.isEmpty ? nil : self.dependencies
        bson[.package] = self.symbol.package
        bson[.version] = self.symbol.version

        bson[.display] = self.display
        bson[.refname] = self.refname

        bson[.latest] = self.latest ? true : nil
        bson[.realm] = self.realm
        bson[.patch] = self.patch

        bson[.products] = Unidoc.NounTable.init(eliding: self.products)
        bson[.cultures] = Unidoc.NounTable.init(eliding: self.cultures)

        //  The `.bson` suffix really isn’t necessary here, but I’ve written it here to
        //  emphasize the type of this field is a raw ``BSON.Identifier`` and not a vertex
        //  scalar.
        bson[.min] = self.id.min.bson
        bson[.max] = self.id.max.bson

        bson[.abi] = self.abi
    }
}
extension Unidoc.VolumeMetadata:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(id: try bson[.id].decode(),
            dependencies: try bson[.dependencies]?.decode() ?? [],
            display: try bson[.display]?.decode(),
            refname: try bson[.refname]?.decode(),
            symbol: .init(
                package: try bson[.package].decode(),
                version: try bson[.version].decode()),
            latest: try bson[.latest]?.decode() ?? false,
            realm: try bson[.realm]?.decode(),
            patch: try bson[.patch]?.decode(),
            products: try bson[.products]?.decode(
                as: Unidoc.NounTable.self, with: \.rows) ?? [],
            cultures: try bson[.cultures]?.decode(
                as: Unidoc.NounTable.self, with: \.rows) ?? [])

        self.abi = try bson[.abi].decode()
    }
}
