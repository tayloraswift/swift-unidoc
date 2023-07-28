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

extension Record
{
    @frozen public
    enum Master:Equatable, Sendable
    {
        case article(Article)
        case culture(Culture)
        case decl(Decl)
        case file(File)
    }
}
extension Record.Master:Identifiable
{
    @inlinable public
    var id:Unidoc.Scalar
    {
        switch self
        {
        case .article(let article): return article.id
        case .culture(let culture): return culture.id
        case .decl(let decl):       return decl.id
        case .file(let file):       return file.id
        }
    }
}
extension Record.Master
{
    @inlinable public
    var overview:Record.Passage?
    {
        switch self
        {
        case .article(let article): return article.overview
        case .culture(let culture): return culture.overview
        case .decl(let decl):       return decl.overview
        case .file:                 return nil
        }
    }
    @inlinable public
    var details:Record.Passage?
    {
        switch self
        {
        case .article(let article): return article.details
        case .culture(let culture): return culture.details
        case .decl(let decl):       return decl.details
        case .file:                 return nil
        }
    }
    @inlinable public
    var stem:Record.Stem?
    {
        switch self
        {
        case .article(let article): return article.stem
        case .culture(let culture): return culture.stem
        case .decl(let decl):       return decl.stem
        case .file:                 return nil
        }
    }
}
extension Record.Master
{
    @frozen public
    enum CodingKey:String
    {
        /// Always present.
        case id = "_id"

        /// Appears in ``Article`` and ``Decl``. The field contains a scalar.
        case culture = "c"
        /// Appears in ``Article``, ``Culture``, and ``Decl``, but may be computed
        /// at encoding-time.
        case stem = "U"

        /// Discriminator for ``Module``.
        case module = "M"

        /// Discriminator for ``File``.
        case file = "F"

        /// Discriminator for ``Decl``.
        case decl = "D"
        /// Only appears in ``Decl``.
        case flags = "Z"
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
        /// Only appears in ``Decl``. The field contains a list of scalars.
        case superforms = "p"
        /// Only appears in ``Decl``, and only when different from ``culture``.
        /// The field contains a scalar.
        case namespace = "n"
        /// Only appears in ``Decl``. The field contains a list of scalars.
        case scope = "x"

        /// Only appears in ``Decl``.
        case position = "P"
        /// Only appears in ``Decl``. The field contains a scalar.
        case location = "l"

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

        /// Contains a list of precomputed zones, as MongoDB cannot easily
        /// convert scalars to zones. This field will be computed and
        /// encoded if non-empty, but it will never be decoded.
        case zones = "z"

        /// Optional FNV24 hash of the record’s symbol. Currently only computed
        /// for ``Decl`` records.
        case hash = "H"
    }
}
extension Record.Master:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id

        //  Masters never appear outside their native zone.
        var zones:Unidoc.ZoneSet = .init(except: self.id.zone)

        switch self
        {
        case .file(let self):
            bson[.file] = self.symbol

        case .decl(let self):
            bson[.decl] = self.symbol

            bson[.flags] = Unidoc.Decl.Flags.init(
                customization: self.customization,
                phylum: self.phylum,
                route: self.route)

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

            bson[.stem] = self.stem

            bson[.superforms] = self.superforms.isEmpty ? nil : self.superforms
            bson[.namespace] = self.culture == self.namespace ? nil : self.namespace
            bson[.culture] = self.culture
            bson[.scope] = self.scope.isEmpty ? nil : self.scope
            bson[.file] = self.file
            bson[.position] = self.position

            zones.update(with: self.signature.expanded.scalars)
            zones.update(with: self.signature.generics.constraints)

            zones.update(with: self.superforms)
            zones.update(with: self.namespace.zone)
            zones.update(with: self.culture.zone)
            zones.update(with: self.scope)

            bson[.hash] = FNV24.init(hashing: "\(self.symbol)")

        case .culture(let self):
            bson[.module] = self.module
            bson[.stem] = self.stem


        case .article(let self):
            bson[.stem] = self.stem
            bson[.culture] = self.culture
            bson[.headline] = self.headline
        }

        zones.update(with: self.overview?.outlines ?? [])
        zones.update(with: self.details?.outlines ?? [])

        bson[.overview] = self.overview
        bson[.details] = self.details

        bson[.zones] = zones.ordered.isEmpty ? nil : zones.ordered
    }
}
extension Record.Master:BSONDocumentDecodable
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
                overview: try bson[.overview]?.decode(),
                details: try bson[.details]?.decode()))

        case .decl?:
            let flags:Unidoc.Decl.Flags = try bson[.flags].decode()
            let culture:Unidoc.Scalar = try bson[.culture].decode()

            self = .decl(.init(id: id,
                customization: flags.customization,
                phylum: flags.phylum,
                route: flags.route,
                signature: .init(
                    availability: try bson[.signature_availability]?.decode() ?? .init(),
                    abridged: Signature<Unidoc.Scalar?>.Abridged.init(
                        bytecode: try bson[.signature_abridged_bytecode].decode()),
                    expanded: Signature<Unidoc.Scalar?>.Expanded.init(
                        bytecode: try bson[.signature_expanded_bytecode].decode(),
                        scalars: try bson[.signature_expanded_scalars]?.decode() ?? []),
                    generics: Signature<Unidoc.Scalar?>.Generics.init(
                        constraints: try bson[.signature_generics_constraints]?.decode() ?? [],
                        parameters: try bson[.signature_generics_parameters]?.decode() ?? [])),
                symbol: try bson[.decl].decode(),
                stem: try bson[.stem].decode(),
                superforms: try bson[.superforms]?.decode() ?? [],
                namespace: try bson[.namespace]?.decode() ?? culture,
                culture: culture,
                scope: try bson[.scope]?.decode() ?? [],
                file: try bson[.file]?.decode(),
                position: try bson[.position]?.decode(),
                overview: try bson[.overview]?.decode(),
                details: try bson[.details]?.decode()))

        case .file?:
            self = .file(.init(id: id, symbol: try bson[.file].decode()))

        case _:
            self = .article(.init(id: id,
                stem: try bson[.stem].decode(),
                culture: try bson[.culture].decode(),
                headline: try bson[.headline].decode(),
                overview: try bson[.overview]?.decode(),
                details: try bson[.details]?.decode()))
        }
    }
}
