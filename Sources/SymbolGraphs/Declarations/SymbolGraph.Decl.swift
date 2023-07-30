import Availability
import BSONDecoding
import BSONEncoding
import LexicalPaths
import Signatures
import Sources
import Unidoc

extension SymbolGraph
{
    @frozen public
    struct Decl:Equatable, Sendable
    {
        public
        let customization:Unidoc.Decl.Customization
        public
        let phylum:Unidoc.Decl
        public
        var route:Unidoc.Decl.Route

        public
        let path:UnqualifiedPath

        /// This scalar’s declaration, which consists of its availability,
        /// syntax fragments, and generic signature.
        public
        var signature:Signature<Int32>
        /// The location of this scalar’s declaration, if known.
        public
        var location:SourceLocation<Int32>?
        /// This scalar’s binary markdown documentation, if it has any.
        public
        var article:Article?

        /// The addresses of the scalars that this scalar implements,
        /// overrides, or inherits from. Superforms are intrinsic but there
        /// can be more than one per scalar.
        ///
        /// All of the superforms in this array have the same relationship
        /// to this declaration; the relationship type is a function of
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

        @inlinable internal
        init(customization:Unidoc.Decl.Customization,
            phylum:Unidoc.Decl,
            route:Unidoc.Decl.Route,
            path:UnqualifiedPath,
            signature:Signature<Int32> = .init(),
            location:SourceLocation<Int32>? = nil,
            article:Article? = nil,
            superforms:[Int32] = [],
            features:[Int32] = [],
            origin:Int32? = nil)
        {
            self.customization = customization
            self.phylum = phylum
            self.route = route
            self.path = path

            self.signature = signature
            self.location = location
            self.article = article

            self.superforms = superforms
            self.features = features
            self.origin = origin
        }
    }
}
extension SymbolGraph.Decl
{
    @inlinable public
    init(customization:Unidoc.Decl.Customization, phylum:Unidoc.Decl, path:UnqualifiedPath)
    {
        self.init(customization: customization,
            phylum: phylum,
            route: .unhashed,
            path: path)
    }
}
extension SymbolGraph.Decl
{
    @frozen public
    enum CodingKey:String
    {
        case flags = "X"
        case path = "P"

        case signature_availability = "V"
        case signature_abridged_bytecode = "B"
        case signature_expanded_bytecode = "E"
        case signature_expanded_scalars = "K"
        case signature_generics_constraints = "C"
        case signature_generics_parameters = "G"

        case superforms = "S"
        case features = "F"
        case origin = "O"

        case location = "L"
        case article = "A"
    }
}
extension SymbolGraph.Decl:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.flags] = Unidoc.Decl.Flags.init(
            customization: self.customization,
            phylum: self.phylum,
            route: self.route)

        bson[.path] = self.path.joined(separator: " ")

        bson[.signature_availability] =
            self.signature.availability.isEmpty ? nil :
            self.signature.availability

        bson[.signature_abridged_bytecode] = self.signature.abridged.bytecode
        bson[.signature_expanded_bytecode] = self.signature.expanded.bytecode
        //  TODO: optimize
        bson[.signature_expanded_scalars] =
            self.signature.expanded.scalars.isEmpty ? nil :
            self.signature.expanded.scalars

        bson[.signature_generics_constraints] =
            self.signature.generics.constraints.isEmpty ? nil :
            self.signature.generics.constraints

        bson[.signature_generics_parameters] =
            self.signature.generics.parameters.isEmpty ? nil :
            self.signature.generics.parameters

        bson[.superforms] = SymbolGraph.Buffer.init(elidingEmpty: self.superforms)
        bson[.features] = SymbolGraph.Buffer.init(elidingEmpty: self.features)

        bson[.origin] = self.origin

        bson[.location] = self.location
        bson[.article] = self.article
    }
}
extension SymbolGraph.Decl:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        let flags:Unidoc.Decl.Flags = try bson[.flags].decode()
        self.init(
            customization: flags.customization,
            phylum: flags.phylum,
            route: flags.route,
            path: try bson[.path].decode(),
            //  Adding the type names here *massively* improves compilation times, for
            //  some reason...
            signature: .init(
                availability: try bson[.signature_availability]?.decode() ?? .init(),
                abridged: Signature<Int32>.Abridged.init(
                    bytecode: try bson[.signature_abridged_bytecode].decode()),
                expanded: Signature<Int32>.Expanded.init(
                    bytecode: try bson[.signature_expanded_bytecode].decode(),
                    scalars: try bson[.signature_expanded_scalars]?.decode() ?? []),
                generics: Signature<Int32>.Generics.init(
                    constraints: try bson[.signature_generics_constraints]?.decode() ?? [],
                    parameters: try bson[.signature_generics_parameters]?.decode() ?? [])),

            location: try bson[.location]?.decode(),
            article: try bson[.article]?.decode(),
            superforms: try bson[.superforms]?.decode(
                as: SymbolGraph.Buffer.self, with: \.elements) ?? [],
            features: try bson[.features]?.decode(
                as: SymbolGraph.Buffer.self, with: \.elements) ?? [],
            origin: try bson[.origin]?.decode())
    }
}
