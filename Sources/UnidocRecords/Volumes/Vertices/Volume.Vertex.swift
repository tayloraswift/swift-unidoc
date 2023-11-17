import Availability
import BSONDecoding
import BSONEncoding
import FNV1
import MarkdownABI
import ModuleGraphs
import Signatures
import SymbolGraphs
import Symbols
import Unidoc

extension Volume
{
    @frozen public
    enum Vertex:Equatable, Sendable
    {
        case article(Article)
        case culture(Culture)
        case decl(Decl)
        case file(File)
        case foreign(Foreign)
        case global(Global)
    }
}
extension Volume.Vertex
{
    @inlinable public
    var article:Article?
    {
        switch self
        {
        case .article(let article): article
        case _:                     nil
        }
    }
    @inlinable public
    var culture:Culture?
    {
        switch self
        {
        case .culture(let culture): culture
        case _:                     nil
        }
    }
    @inlinable public
    var decl:Decl?
    {
        switch self
        {
        case .decl(let decl):       decl
        case _:                     nil
        }
    }
    @inlinable public
    var file:File?
    {
        switch self
        {
        case .file(let file):       file
        case _:                     nil
        }
    }
    @inlinable public
    var foreign:Foreign?
    {
        switch self
        {
        case .foreign(let foreign): foreign
        case _:                     nil
        }
    }
    @inlinable public
    var global:Global?
    {
        switch self
        {
        case .global(let global):   global
        case _:                     nil
        }
    }
}
extension Volume.Vertex:Identifiable
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
        case .foreign(let foreign): foreign.id
        case .global(let global):   global.id
        }
    }
}
extension Volume.Vertex
{
    @inlinable public
    var overview:Volume.Passage?
    {
        switch self
        {
        case .article(let article): article.overview
        case .culture(let culture): culture.overview
        case .decl(let decl):       decl.overview
        case .file:                 nil
        case .foreign:              nil
        case .global:               nil
        }
    }
    @inlinable public
    var details:Volume.Passage?
    {
        switch self
        {
        case .article(let article): article.details
        case .culture(let culture): culture.details
        case .decl(let decl):       decl.details
        case .file:                 nil
        case .foreign:              nil
        case .global:               nil
        }
    }
    @inlinable public
    var shoot:Volume.Shoot?
    {
        switch self
        {
        case .article(let article): article.shoot
        case .culture(let culture): culture.shoot
        case .decl(let decl):       decl.shoot
        case .file:                 nil
        case .foreign(let foreign): foreign.shoot
        case .global:               nil
        }
    }
}
extension Volume.Vertex
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
        case zone = "Z"

        /// Appears in ``Foreign`` only.
        case extendee = "j"
        /// Appears in ``Article``, ``Decl``, ``Culture``, and ``File``.
        case symbol = "Y"
        /// Appears in every vertex type except for ``File``. In ``Global``, it is always the
        /// empty string.
        case stem = "U"

        /// Appears in ``Culture`` only.
        case census = "S"

        /// Only appears in ``Culture``.
        case module = "M"

        /// Appears in ``Decl`` and ``Foreign``.
        case flags = "F"
        /// Only appears in ``Decl``.
        case signature_availability = "A"
        /// Only appears in ``Decl``.
        case signature_abridged_bytecode = "B"
        /// Only appears in ``Decl``.
        case signature_expanded_bytecode = "E"
        /// Only appears in ``Decl``. The field contains a list of scalars.
        case signature_expanded_scalars = "e"
        /// Only appears in ``Decl``. The field contains a list of constraints,
        /// which contain scalars.
        case signature_generics_constraints = "g"
        /// Only appears in ``Decl``.
        case signature_generics_parameters = "G"
        /// Only appears in ``Decl``.
        case signature_spis = "I"
        /// Only appears in ``Decl``. The field contains a list of scalars.
        case requirements = "r"
        /// Only appears in ``Decl``. The field contains a list of scalars.
        case superforms = "p"
        /// Only appears in ``Decl``, and only when different from ``culture``.
        /// The field contains a scalar.
        case namespace = "n"
        /// Appears in ``Article`` and ``Decl``. The field contains a scalar.
        case culture = "c"
        /// Only appears in ``Decl``. The field contains a list of scalars.
        case scope = "x"
        /// Can appear in ``Article``, ``Culture``, or ``Decl``.
        /// The field contains a scalar. In ``Culture``, it points to the readme
        /// article for the module.
        case file = "f"

        /// Only appears in ``Decl``.
        case position = "P"

        /// Only appears in ``Article``.
        case headline = "T"
        /// Optional, but can appear in any master record.
        /// The field contains a passage, which contains a list of outlines,
        /// each of which may contain a scalar.
        case overview = "o"
        /// Optional, but can appear in any master record.
        /// The field contains a passage, which contains a list of outlines,
        /// each of which may contain a scalar.
        case details = "d"

        /// Can appear in any master record except a ``File``.
        /// The field contains a *group* scalar. (Not a master scalar!)
        case group = "t"

        /// Extended FNV24 hash of the record’s symbol, appears in every vertex type except
        /// for ``File``. In ``Global``, it is always zero.
        case hash = "H"
    }
}
extension Volume.Vertex:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.zone] = self.id.zone

        switch self
        {
        case .article(let self):
            //  This allows us to correlate article identifiers across different versions.
            //  Articles are so few in number that we can afford to duplicate this.
            bson[.symbol] = self.stem
            bson[.hash] = FNV24.Extended.init(hashing: "\(self.stem)")
            bson[.stem] = self.stem

            bson[.culture] = self.culture
            bson[.file] = self.file
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

            bson[.requirements] = self.requirements.isEmpty ? nil : self.requirements
            bson[.superforms] = self.superforms.isEmpty ? nil : self.superforms
            bson[.namespace] = self.culture == self.namespace ? nil : self.namespace
            bson[.culture] = self.culture
            bson[.scope] = self.scope.isEmpty ? nil : self.scope
            bson[.file] = self.file

            bson[.position] = self.position
            bson[.overview] = self.overview
            bson[.details] = self.details
            bson[.group] = self.group

        case .culture(let self):
            //  Save this because it is computed by mangling a target name.
            let module:ModuleIdentifier = self.module.id
            //  This allows us to correlate modules identifiers across different versions.
            bson[.symbol] = module
            bson[.hash] = FNV24.Extended.init(hashing: "s:m:\(module)")
            bson[.stem] = self.stem

            bson[.module] = self.module
            bson[.file] = self.readme
            bson[.census] = self.census

            bson[.overview] = self.overview
            bson[.details] = self.details
            bson[.group] = self.group

        case .file(let self):
            bson[.symbol] = self.symbol

        case .foreign(let self):
            bson[.extendee] = self.extendee
            bson[.scope] = self.scope.isEmpty ? nil : self.scope
            bson[.flags] = self.flags
            bson[.hash] = self.hash
            bson[.stem] = self.stem

        case .global:
            //  This must have a value, otherwise it would get lost among all the file
            //  vertices, and queries for it would be very slow.
            bson[.hash] = 0
            bson[.stem] = ""
        }
    }
}
extension Volume.Vertex:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        let id:Unidoc.Scalar = try bson[.id].decode()

        switch id.plane
        {
        case .module?:
            self = .culture(.init(id: id,
                module: try bson[.module].decode(),
                readme: try bson[.file]?.decode(),
                census: try bson[.census].decode(),
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
                requirements: try bson[.requirements]?.decode() ?? [],
                superforms: try bson[.superforms]?.decode() ?? [],
                namespace: try bson[.namespace]?.decode() ?? culture,
                culture: culture,
                scope: try bson[.scope]?.decode() ?? [],
                file: try bson[.file]?.decode(),
                position: try bson[.position]?.decode(),
                overview: try bson[.overview]?.decode(),
                details: try bson[.details]?.decode(),
                group: try bson[.group]?.decode()))

        case .article?:
            self = .article(.init(id: id,
                stem: try bson[.stem].decode(),
                culture: try bson[.culture].decode(),
                file: try bson[.file]?.decode(),
                headline: try bson[.headline].decode(),
                overview: try bson[.overview]?.decode(),
                details: try bson[.details]?.decode(),
                group: try bson[.group]?.decode()))

        case .file?:
            self = .file(.init(id: id, symbol: try bson[.symbol].decode()))

        case .foreign?:
            self = .foreign(.init(id: id,
                extendee: try bson[.extendee].decode(),
                scope: try bson[.scope]?.decode() ?? [],
                flags: try bson[.flags].decode(),
                stem: try bson[.stem].decode(),
                hash: try bson[.hash].decode()))

        case _:
            self = .global(.init(id: id))
        }
    }
}
