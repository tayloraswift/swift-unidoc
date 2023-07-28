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
        case .file(let file):
            bson[.file] = file.symbol

        case .decl(let decl):
            bson[.decl] = decl.symbol

            bson[.flags] = Unidoc.Decl.Flags.init(
                customization: decl.customization,
                phylum: decl.phylum,
                route: decl.route)

            bson[.signature_availability] =
                decl.signature.availability.isEmpty ? nil :
                decl.signature.availability

            bson[.signature_abridged_bytecode] = decl.signature.abridged.bytecode
            bson[.signature_expanded_bytecode] = decl.signature.expanded.bytecode

            bson[.signature_expanded_scalars] =
                decl.signature.expanded.scalars.isEmpty ? nil :
                decl.signature.expanded.scalars

            bson[.signature_generics_constraints] =
                decl.signature.generics.constraints.isEmpty ? nil :
                decl.signature.generics.constraints

            bson[.signature_generics_parameters] =
                decl.signature.generics.parameters.isEmpty ? nil :
                decl.signature.generics.parameters

            bson[.stem] = decl.stem

            bson[.superforms] = decl.superforms.isEmpty ? nil : decl.superforms
            bson[.namespace] = decl.culture == decl.namespace ? nil : decl.namespace
            bson[.culture] = decl.culture
            bson[.scope] = decl.scope.isEmpty ? nil : decl.scope
            bson[.file] = decl.file
            bson[.position] = decl.position

            zones.update(with: decl.signature.expanded.scalars)
            zones.update(with: decl.signature.generics.constraints)

            zones.update(with: decl.superforms)
            zones.update(with: decl.namespace.zone)
            zones.update(with: decl.culture.zone)
            zones.update(with: decl.scope)

            bson[.hash] = FNV24.init(hashing: "\(decl.symbol)")

        case .culture(let culture):
            bson[.module] = culture.module
            bson[.stem] = culture.stem


        case .article(let article):
            bson[.stem] = article.stem
            bson[.culture] = article.culture
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

        let overview:Record.Passage? = try bson[.overview]?.decode()
        let details:Record.Passage? = try bson[.details]?.decode()

        if      let discriminator:Symbol.Decl = try bson[.decl]?.decode()
        {
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
                symbol: discriminator,
                stem: try bson[.stem].decode(),
                superforms: try bson[.superforms]?.decode() ?? [],
                namespace: try bson[.namespace]?.decode() ?? culture,
                culture: culture,
                scope: try bson[.scope]?.decode() ?? [],
                file: try bson[.file]?.decode(),
                position: try bson[.position]?.decode(),
                overview: overview,
                details: details))
        }
        else if let discriminator:Symbol.File = try bson[.file]?.decode()
        {
            self = .file(.init(id: id, symbol: discriminator))
        }
        else if let discriminator:ModuleDetails = try bson[.module]?.decode()
        {
            self = .culture(.init(id: id,
                module: discriminator,
                overview: overview,
                details: details))
        }
        else
        {
            self = .article(.init(id: id,
                stem: try bson[.stem].decode(),
                culture: try bson[.culture].decode(),
                overview: overview,
                details: details))
        }
    }
}
