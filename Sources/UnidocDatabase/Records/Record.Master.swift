import Availability
import BSONDecoding
import BSONEncoding
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
        }
    }
}
extension Record.Master
{
    @frozen public
    enum CodingKeys:String
    {
        /// Always present.
        case id = "_id"
        /// Always present, but may have a varying type.
        case stem = "U"

        /// Discriminator for ``Module``.
        case module = "M"

        /// Discriminator for ``Decl``.
        case symbol = "S"
        /// Only appears in ``Decl``.
        case signature_availability = "V"
        /// Only appears in ``Decl``.
        case signature_abridged_bytecode = "B"
        /// Only appears in ``Decl``.
        case signature_expanded_bytecode = "E"
        /// Only appears in ``Decl``.
        case signature_expanded_links = "K"
        /// Only appears in ``Decl``.
        case signature_generics_constraints = "C"
        /// Only appears in ``Decl``.
        case signature_generics_parameters = "G"
        /// Only appears in ``Decl``.
        case superforms = "P"
        /// Only appears in ``Decl``.
        case culture = "X"
        /// Only appears in ``Decl``.
        case scope = "R"

        /// Optional, but can appear in any master record.
        case overview = "O"
        /// Optional, but can appear in any master record.
        case details = "D"
    }

    static
    subscript(key:CodingKeys) -> BSON.Key { .init(key) }
}
extension Record.Master:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.id] = self.id

        switch self
        {
        case .decl(let decl):
            bson[.symbol] = decl.symbol

            bson[.signature_availability] =
                decl.signature.availability.isEmpty ? nil :
                decl.signature.availability

            bson[.signature_abridged_bytecode] = decl.signature.abridged.bytecode
            bson[.signature_expanded_bytecode] = decl.signature.expanded.bytecode

            bson[.signature_expanded_links] =
                decl.signature.expanded.links.isEmpty ? nil :
                decl.signature.expanded.links

            bson[.signature_generics_constraints] =
                decl.signature.generics.constraints.isEmpty ? nil :
                decl.signature.generics.constraints

            bson[.signature_generics_parameters] =
                decl.signature.generics.parameters.isEmpty ? nil :
                decl.signature.generics.parameters

            bson[.stem] = decl.stem
            bson[.superforms] = decl.superforms.isEmpty ? nil : decl.superforms
            bson[.culture] = decl.culture
            bson[.scope] = decl.scope.isEmpty ? nil : decl.scope

        case .culture(let culture):
            bson[.module] = culture.module
            bson[.stem] = culture.stem

        case .article(let article):
            bson[.stem] = article.stem
        }

        bson[.overview] = self.overview
        bson[.details] = self.details
    }
}
extension Record.Master:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        let id:Unidoc.Scalar = try bson[.id].decode()

        let overview:Record.Passage? = try bson[.overview]?.decode()
        let details:Record.Passage? = try bson[.details]?.decode()

        if      let discriminator:Symbol.Decl = try bson[.symbol]?.decode()
        {
            self = .decl(.init(id: id,
                signature: .init(
                    availability: try bson[.signature_availability]?.decode() ?? .init(),
                    abridged: Signature<Unidoc.Scalar?>.Abridged.init(
                        bytecode: try bson[.signature_abridged_bytecode].decode()),
                    expanded: Signature<Unidoc.Scalar?>.Expanded.init(
                        bytecode: try bson[.signature_expanded_bytecode].decode(),
                        links: try bson[.signature_expanded_links]?.decode() ?? []),
                    generics: Signature<Unidoc.Scalar?>.Generics.init(
                        constraints: try bson[.signature_generics_constraints]?.decode() ?? [],
                        parameters: try bson[.signature_generics_parameters]?.decode() ?? [])),
                symbol: discriminator,
                stem: try bson[.stem].decode(),
                superforms: try bson[.superforms]?.decode() ?? [],
                culture: try bson[.culture].decode(),
                scope: try bson[.scope]?.decode() ?? [],
                overview: overview,
                details: details))
        }
        else if let discriminator:ModuleDetails = try bson[.module]?.decode()
        {
            self = .culture(.init(id: id,
                module: discriminator,
                stem: try bson[.stem].decode(),
                overview: overview,
                details: details))
        }
        else
        {
            self = .article(.init(id: id,
                stem: try bson[.stem].decode(),
                overview: overview,
                details: details))
        }
    }
}
