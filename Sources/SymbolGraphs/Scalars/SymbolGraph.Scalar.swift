import Availability
import BSONDecoding
import BSONEncoding
import Declarations
import Generics
import LexicalPaths
import Symbols

extension SymbolGraph
{
    @frozen public
    struct Scalar:Equatable, Sendable
    {
        public
        let flags:Flags
        public
        let path:UnqualifiedPath

        /// This scalar’s declaration, which consists of its availability,
        /// syntax fragments, and generic signature.
        public
        var declaration:Declaration<ScalarAddress>

        /// The addresses of the scalars that this scalar implements,
        /// overrides, or inherits from. Superforms are intrinsic but there
        /// can be more than one per scalar.
        ///
        /// All of the superforms in this array have the same relationship
        /// to this scalar; the relationship type is a function of
        /// ``aperture`` and ``phylum``.
        public
        var superforms:[ScalarAddress]
        /// The addresses of the *unqualified* features inherited by this
        /// scalar. Unqualified features are protocol extension members that
        /// were inherited by a concrete type, but for which we are missing
        /// their extension constraints.
        ///
        /// This field only exists because of an upstream bug in SymbolGraphGen.
        public
        var features:[ScalarAddress]
        /// The address of a scalar that has documentation that is relevant,
        /// but less specific to this scalar.
        public
        var origin:ScalarAddress?

        /// The location of this scalar’s declaration, if known.
        public
        var location:SourceLocation<FileAddress>?
        /// This scalar’s binary markdown documentation, if it has any.
        public
        var article:Article?

        @inlinable public
        init(flags:Flags, path:UnqualifiedPath)
        {
            self.flags = flags
            self.path = path

            self.declaration = .init()

            self.superforms = []
            self.features = []
            self.origin = nil

            self.location = nil
            self.article = nil
        }
    }
}
extension SymbolGraph.Scalar
{
    @inlinable public
    var aperture:ScalarAperture { self.flags.aperture }
    @inlinable public
    var phylum:ScalarPhylum { self.flags.phylum }
}
extension SymbolGraph.Scalar
{
    @frozen public
    enum CodingKeys:String
    {
        case flags = "X"
        case path = "P"

        case declaration_availability = "V"
        case declaration_abridged_bytecode = "B"
        case declaration_expanded_bytecode = "E"
        case declaration_expanded_links = "K"
        case declaration_generics_constraints = "C"
        case declaration_generics_parameters = "G"

        case superforms = "S"
        case features = "F"
        case origin = "O"

        case location = "L"
        case article = "A"
    }
}
extension SymbolGraph.Scalar:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.flags] = self.flags
        bson[.path] = self.path.joined(separator: " ")

        bson[.declaration_availability] =
            self.declaration.availability.isEmpty ? nil :
            self.declaration.availability

        bson[.declaration_abridged_bytecode] = self.declaration.abridged.bytecode
        bson[.declaration_expanded_bytecode] = self.declaration.expanded.bytecode
        //  TODO: optimize
        bson[.declaration_expanded_links] =
            self.declaration.expanded.links.isEmpty ? nil :
            self.declaration.expanded.links

        bson[.declaration_generics_constraints] =
            self.declaration.generics.constraints.isEmpty ? nil :
            self.declaration.generics.constraints

        bson[.declaration_generics_parameters] =
            self.declaration.generics.parameters.isEmpty ? nil :
            self.declaration.generics.parameters

        bson[.superforms] =
            self.superforms.isEmpty ? nil :
            self.superforms

        bson[.features] =
            self.features.isEmpty ? nil :
            self.features

        bson[.origin] = self.origin

        bson[.location] = self.location
        bson[.article] = self.article
    }
}
extension SymbolGraph.Scalar:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            flags: try bson[.flags].decode(),
            path: try bson[.path].decode())

        self.declaration = .init(
            availability: try bson[.declaration_availability]?.decode() ?? .init(),
            abridged: .init(
                bytecode: try bson[.declaration_abridged_bytecode].decode()),
            expanded: .init(
                bytecode: try bson[.declaration_expanded_bytecode].decode(),
                links: try bson[.declaration_expanded_links]?.decode() ?? []),
            generics: .init(
                constraints: try bson[.declaration_generics_constraints]?.decode() ?? [],
                parameters: try bson[.declaration_generics_parameters]?.decode() ?? []))

        self.superforms = try bson[.superforms]?.decode() ?? []
        self.features = try bson[.features]?.decode() ?? []
        self.origin = try bson[.origin]?.decode()

        self.location = try bson[.location]?.decode()
        self.article = try bson[.article]?.decode()
    }
}
