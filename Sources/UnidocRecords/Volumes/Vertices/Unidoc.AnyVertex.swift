import Availability
import BSON
import FNV1
import MarkdownABI
import Signatures
import SymbolGraphs
import Symbols
import Unidoc
import UnidocAPI

extension Unidoc
{
    @frozen public
    enum AnyVertex:Equatable, Sendable
    {
        case article(ArticleVertex)
        case culture(CultureVertex)
        case decl(DeclVertex)
        case file(FileVertex)
        case product(ProductVertex)
        case foreign(ForeignVertex)
        case landing(LandingVertex)
    }
}
extension Unidoc.AnyVertex
{
    @inlinable public
    var article:Unidoc.ArticleVertex?
    {
        switch self
        {
        case .article(let article): article
        case _:                     nil
        }
    }
    @inlinable public
    var culture:Unidoc.CultureVertex?
    {
        switch self
        {
        case .culture(let culture): culture
        case _:                     nil
        }
    }
    @inlinable public
    var decl:Unidoc.DeclVertex?
    {
        switch self
        {
        case .decl(let decl):       decl
        case _:                     nil
        }
    }
    @inlinable public
    var file:Unidoc.FileVertex?
    {
        switch self
        {
        case .file(let file):       file
        case _:                     nil
        }
    }
    @inlinable public
    var product:Unidoc.ProductVertex?
    {
        switch self
        {
        case .product(let product): product
        case _:                     nil
        }
    }
    @inlinable public
    var foreign:Unidoc.ForeignVertex?
    {
        switch self
        {
        case .foreign(let foreign): foreign
        case _:                     nil
        }
    }
    @inlinable public
    var landing:Unidoc.LandingVertex?
    {
        switch self
        {
        case .landing(let landing): landing
        case _:                     nil
        }
    }
}
extension Unidoc.AnyVertex:Identifiable
{
    @inlinable public
    var id:Unidoc.Scalar
    {
        switch self
        {
        case .article(let article): article.id
        case .culture(let culture): culture.id
        case .decl(let decl):       decl.id
        case .file(let file):       file.id
        case .product(let product): product.id
        case .foreign(let foreign): foreign.id
        case .landing(let landing): landing.id
        }
    }
}
extension Unidoc.AnyVertex
{
    @inlinable public
    var overview:Unidoc.Passage?
    {
        switch self
        {
        case .article(let article): article.overview
        case .culture(let culture): culture.overview
        case .decl(let decl):       decl.overview
        case .file:                 nil
        case .product:              nil
        case .foreign:              nil
        case .landing:              nil
        }
    }
    @inlinable public
    var details:Unidoc.Passage?
    {
        switch self
        {
        case .article(let article): article.details
        case .culture(let culture): culture.details
        case .decl(let decl):       decl.details
        case .file:                 nil
        case .product:              nil
        case .foreign:              nil
        case .landing:              nil
        }
    }
    @inlinable public
    var shoot:Unidoc.Shoot?
    {
        switch self
        {
        case .article(let article): article.shoot
        case .culture(let culture): culture.shoot
        case .decl(let decl):       decl.shoot
        case .file:                 nil
        case .product(let product): product.shoot
        case .foreign(let foreign): foreign.shoot
        case .landing(let landing): landing.shoot
        }
    }
}
extension Unidoc.AnyVertex
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        /// Always present.
        case id = "_id"

        /// Always present, computed from ``id``. This field will never be decoded.
        ///
        /// This field is cheap (64-bit integer plus 3 bytes of keying overhead) and
        /// allows us to reuse compound indices for zone-bound queries by performing
        /// an equality match instead of a range match.
        case volume = "Z"

        /// Appears in ``ForeignVertex`` only.
        case extendee = "j"
        /// Appears in ``ArticleVertex``, ``DeclVertex``, ``CultureVertex``, and ``FileVertex``.
        case symbol = "Y"
        /// Appears in every vertex type except for ``FileVertex``. In ``LandingVertex``, it is
        /// always the empty string.
        case stem = "U"

        /// Appears in ``LandingVertex`` only.
        case packages = "k"
        /// Appears in ``LandingVertex`` only.
        case snapshot = "O"

        /// Appears in ``CultureVertex`` only.
        case census = "S"

        /// Only appears in ``CultureVertex``.
        case module = "M"

        /// Only appears in ``ProductVertex``.
        case product = "D"
        /// Only appears in ``ProductVertex``. The field contains a list of scalars.
        case constituents = "r"

        /// Appears in ``DeclVertex`` and ``ForeignVertex``.
        case flags = "L"

        /// Only appears in ``DeclVertex``.
        case signature_availability = "A"
        /// Only appears in ``DeclVertex``.
        case signature_abridged_bytecode = "B"
        /// Only appears in ``DeclVertex``.
        case signature_expanded_bytecode = "E"
        /// Only appears in ``DeclVertex``. The field contains a list of scalars.
        case signature_expanded_scalars = "e"
        /// Only appears in ``DeclVertex``. The field contains a list of constraints,
        /// which contain scalars.
        case signature_generics_constraints = "g"
        /// Only appears in ``DeclVertex``.
        case signature_generics_parameters = "G"
        /// Only appears in ``DeclVertex``.
        case signature_spis = "I"
        /// Only appears in ``DeclVertex``. The field contains a list of scalars.
        case superforms = "p"
        /// Appears in ``ArticleVertex`` and ``DeclVertex``. The field contains a scalar.
        case culture = "c"
        /// Only appears in ``DeclVertex``, and only when different from ``culture``.
        /// The field contains a scalar.
        case colony = "n"
        /// Only appears in ``DeclVertex``. The field contains a list of scalars.
        case scope = "x"

        /// Only appears in ``DeclVertex``. The field contains a scalar.
        case renamed = "a"
        /// Can appear in ``ArticleVertex``, ``CultureVertex``, or ``DeclVertex``.
        /// The field contains a scalar. In ``ArticleVertex`` or ``DeclVertex``, the file
        /// references a markdown supplement.
        case readme = "m"
        /// Only appears in ``DeclVertex``. The field contains a scalar.
        case file = "f"

        /// Only appears in ``DeclVertex``.
        case position = "P"

        /// Used to mark the latest version of article vertices.
        /// This is *not* currently used for URL routing — that goes through volume lookup
        /// instead.
        case linkable = "R"

        /// Appears in ``ArticleVertex``, and sometimes in ``CultureVertex`` as well.
        case headline = "T"
        /// Optional, but can appear in any master record.
        /// The field contains a passage, which contains a list of outlines,
        /// each of which may contain a scalar.
        case overview = "o"
        /// Optional, but can appear in any master record.
        /// The field contains a passage, which contains a list of outlines,
        /// each of which may contain a scalar.
        case details = "d"

        /// Only appears in ``DeclVertex``. The field contains a *group* scalar.
        case peers = "y"
        /// Can appear in any master record except a ``FileVertex``.
        /// The field contains a *group* scalar. (Not a vertex scalar!)
        case group = "t"

        /// Extended FNV24 hash of the record’s symbol, appears in every vertex type except
        /// for ``FileVertex``. In ``LandingVertex``, it is always zero.
        case hash = "H"
    }
}
extension Unidoc.AnyVertex:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.volume] = self.id.edition

        switch self
        {
        case .article(let self):
            //  This allows us to correlate article identifiers across different versions.
            //  Articles are so few in number that we can afford to duplicate this.
            bson[.symbol] = self.stem
            bson[.hash] = self.hash
            bson[.stem] = self.stem

            bson[.culture] = self.culture
            bson[.readme] = self.readme

            bson[.headline] = self.headline
            bson[.overview] = self.overview
            bson[.details] = self.details
            bson[.group] = self.group

        case .decl(let self):
            bson[.symbol] = self.symbol
            bson[.flags] = self.flags
            bson[.hash] = self.hash
            bson[.stem] = self.stem

            bson[.signature_availability] =
                self.signature.availability.isEmpty ? nil :
                self.signature.availability

            bson[.signature_abridged_bytecode] = self.signature.abridged.bytecode
            bson[.signature_expanded_bytecode] = self.signature.expanded.bytecode

            bson[.signature_expanded_scalars] =
                self.signature.expanded.scalars.isEmpty ? nil :
                self.signature.expanded.scalars

            bson[.signature_generics_constraints] =
                self.signature.generics.constraints.isEmpty ? nil :
                self.signature.generics.constraints

            bson[.signature_generics_parameters] =
                self.signature.generics.parameters.isEmpty ? nil :
                self.signature.generics.parameters

            bson[.signature_spis] = self.signature.spis

            //  Deprecated.
            bson[.constituents] = self._requirements.isEmpty ? nil : self._requirements

            bson[.superforms] = self.superforms.isEmpty ? nil : self.superforms
            bson[.culture] = self.culture
            bson[.colony] = self.colony
            bson[.scope] = self.scope.isEmpty ? nil : self.scope
            bson[.renamed] = self.renamed
            bson[.readme] = self.readme
            bson[.file] = self.file

            bson[.position] = self.position
            bson[.overview] = self.overview
            bson[.details] = self.details

            bson[.peers] = self.peers
            bson[.group] = self.group

        case .culture(let self):
            //  This allows us to correlate module identifiers across different versions.
            bson[.symbol] = self.module.id
            bson[.hash] = self.hash
            bson[.stem] = self.stem

            bson[.module] = self.module
            bson[.readme] = self.readme
            bson[.census] = self.census

            bson[.headline] = self.headline
            bson[.overview] = self.overview
            bson[.details] = self.details
            bson[.group] = self.group

        case .file(let self):
            bson[.symbol] = self.symbol

        case .product(let self):
            bson[.symbol] = self.symbol
            //  Product names often shadow module names, so we perturb the hash input to ward
            //  off hash collisions.
            bson[.hash] = self.hash
            bson[.stem] = self.stem
            //  It would be incredibly strange for a product to have no constituents.
            bson[.constituents] = self.constituents
            bson[.product] = self.type
            bson[.group] = self.group

        case .foreign(let self):
            bson[.extendee] = self.extendee
            bson[.scope] = self.scope.isEmpty ? nil : self.scope
            bson[.flags] = self.flags
            bson[.hash] = self.hash
            bson[.stem] = self.stem

        case .landing(let self):
            bson[.hash] = self.hash
            bson[.stem] = self.stem
            bson[.snapshot] = self.snapshot
            bson[.packages] = self.packages.isEmpty ? nil : self.packages
        }
    }
}
extension Unidoc.AnyVertex:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        let id:Unidoc.Scalar = try bson[.id].decode()

        switch id.plane
        {
        case .module?:
            self = .culture(.init(id: id,
                module: try bson[.module].decode(),
                //  Needed until we can migrate the database.
                readme: try bson[.readme]?.decode() ?? bson[.file]?.decode(),
                //  Might be decoding with this key deprojected.
                census: try bson[.census]?.decode() ?? .init(),
                headline: try bson[.headline]?.decode(),
                overview: try bson[.overview]?.decode(),
                details: try bson[.details]?.decode(),
                group: try bson[.group]?.decode()))

        case .decl?:
            let culture:Unidoc.Scalar = try bson[.culture].decode()

            self = .decl(.init(id: id,
                flags: try bson[.flags].decode(),
                signature: .init(
                    availability: try bson[.signature_availability]?.decode() ?? .init(),
                    abridged: Signature<Unidoc.Scalar?>.Abridged.init(
                        bytecode: try bson[.signature_abridged_bytecode].decode()),
                    expanded: Signature<Unidoc.Scalar?>.Expanded.init(
                        bytecode: try bson[.signature_expanded_bytecode].decode(),
                        scalars: try bson[.signature_expanded_scalars]?.decode() ?? []),
                    generics: Signature<Unidoc.Scalar?>.Generics.init(
                        constraints: try bson[.signature_generics_constraints]?.decode() ?? [],
                        parameters: try bson[.signature_generics_parameters]?.decode() ?? []),
                    spis: try bson[.signature_spis]?.decode()),
                symbol: try bson[.symbol].decode(),
                stem: try bson[.stem].decode(),
                _requirements: try bson[.constituents]?.decode() ?? [],
                superforms: try bson[.superforms]?.decode() ?? [],
                namespace: try bson[.colony]?.decode() ?? culture,
                culture: culture,
                scope: try bson[.scope]?.decode() ?? [],
                renamed: try bson[.renamed]?.decode(),
                readme: try bson[.readme]?.decode(),
                file: try bson[.file]?.decode(),
                position: try bson[.position]?.decode(),
                overview: try bson[.overview]?.decode(),
                details: try bson[.details]?.decode(),
                peers: try bson[.peers]?.decode(),
                group: try bson[.group]?.decode()))

        case .article?:
            self = .article(.init(id: id,
                stem: try bson[.stem].decode(),
                culture: try bson[.culture].decode(),
                //  Needed until we can migrate the database.
                readme: try bson[.readme]?.decode() ?? bson[.file]?.decode(),
                headline: try bson[.headline].decode(),
                overview: try bson[.overview]?.decode(),
                details: try bson[.details]?.decode(),
                group: try bson[.group]?.decode()))

        case .file?:
            self = .file(.init(id: id, symbol: try bson[.symbol].decode()))

        case .product?:
            self = .product(.init(id: id,
                //  Although this field is always present in the database, it may be removed
                //  through query projection.
                constituents: try bson[.constituents]?.decode() ?? [],
                symbol: try bson[.symbol].decode(),
                type: try bson[.product].decode(),
                group: try bson[.group]?.decode()))

        case .foreign?:
            self = .foreign(.init(id: id,
                extendee: try bson[.extendee].decode(),
                scope: try bson[.scope]?.decode() ?? [],
                flags: try bson[.flags].decode(),
                stem: try bson[.stem].decode(),
                hash: try bson[.hash].decode()))

        case _:
            self = .landing(.init(id: id,
                snapshot: try bson[.snapshot].decode(),
                packages: try bson[.packages]?.decode() ?? []))
        }
    }
}
