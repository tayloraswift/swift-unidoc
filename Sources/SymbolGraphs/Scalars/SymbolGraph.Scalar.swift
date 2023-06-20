import Availability
import BSONDecoding
import BSONEncoding
import Declarations
import Generics
import LexicalPaths
import Sources
import Symbols

extension SymbolGraph
{
    @frozen public
    struct Scalar:Equatable, Sendable
    {
        @usableFromInline internal
        var flags:Flags

        public
        let path:UnqualifiedPath

        /// This scalar’s declaration, which consists of its availability,
        /// syntax fragments, and generic signature.
        public
        var declaration:Declaration<Int32>

        /// The addresses of the scalars that this scalar implements,
        /// overrides, or inherits from. Superforms are intrinsic but there
        /// can be more than one per scalar.
        ///
        /// All of the superforms in this array have the same relationship
        /// to this scalar; the relationship type is a function of
        /// ``aperture`` and ``phylum``.
        public
        var superforms:[Int32]
        /// The addresses of the *unqualified* features inherited by this
        /// scalar. Unqualified features are protocol extension members that
        /// were inherited by a concrete type, but for which we are missing
        /// their extension constraints.
        ///
        /// This field only exists because of an upstream bug in SymbolGraphGen.
        public
        var features:[Int32]
        /// The address of a scalar that has documentation that is relevant,
        /// but less specific to this scalar.
        public
        var origin:Int32?

        /// The location of this scalar’s declaration, if known.
        public
        var location:SourceLocation<Int32>?
        /// This scalar’s binary markdown documentation, if it has any.
        public
        var article:Article<Never>?

        @inlinable internal
        init(flags:Flags,
            path:UnqualifiedPath,
            declaration:Declaration<Int32> = .init(),
            superforms:[Int32] = [],
            features:[Int32] = [],
            origin:Int32? = nil,
            location:SourceLocation<Int32>? = nil,
            article:Article<Never>? = nil)
        {
            self.flags = flags
            self.path = path

            self.declaration = declaration

            self.superforms = superforms
            self.features = features
            self.origin = origin

            self.location = location
            self.article = article
        }
    }
}
extension SymbolGraph.Scalar
{
    @inlinable public
    init(phylum:ScalarPhylum, aperture:ScalarAperture, path:UnqualifiedPath)
    {
        self.init(flags: .init(phylum: phylum, aperture: aperture, route: .unhashed),
            path: path)
    }
}
extension SymbolGraph.Scalar
{
    @inlinable public
    var aperture:ScalarAperture { self.flags.aperture }

    @inlinable public
    var phylum:ScalarPhylum { self.flags.phylum }

    @inlinable public
    var route:Route
    {
        get
        {
            self.flags.route
        }
        set(value)
        {
            self.flags.route = value
        }
    }
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
            path: try bson[.path].decode(),
            //  Adding the type names here *massively* improves compilation times, for
            //  some reason...
            declaration: .init(
                availability: try bson[.declaration_availability]?.decode() ?? .init(),
                abridged: Declaration<Int32>.Abridged.init(
                    bytecode: try bson[.declaration_abridged_bytecode].decode()),
                expanded: Declaration<Int32>.Expanded.init(
                    bytecode: try bson[.declaration_expanded_bytecode].decode(),
                    links: try bson[.declaration_expanded_links]?.decode() ?? []),
                generics: GenericSignature<Int32>.init(
                    constraints: try bson[.declaration_generics_constraints]?.decode() ?? [],
                    parameters: try bson[.declaration_generics_parameters]?.decode() ?? [])),

            superforms: try bson[.superforms]?.decode() ?? [],
            features: try bson[.features]?.decode() ?? [],
            origin: try bson[.origin]?.decode(),
            location: try bson[.location]?.decode(),
            article: try bson[.article]?.decode())
    }
}
