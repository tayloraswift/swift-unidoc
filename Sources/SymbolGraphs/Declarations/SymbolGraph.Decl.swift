import Availability
import BSON
import LexicalPaths
import Signatures
import Sources
import Symbols

extension SymbolGraph
{
    @frozen public
    struct Decl:Equatable, Sendable
    {
        public
        let language:Phylum.Language
        public
        let phylum:Phylum.Decl
        public
        var kinks:Phylum.Decl.Kinks
        public
        var route:Phylum.Decl.Route

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

        /// Protocol requirements.
        public
        var requirements:[Int32]
        /// Enum cases, if this is an enum.
        public
        var inhabitants:[Int32]
        /// The addresses of the scalars that this scalar implements,
        /// overrides, or inherits from. Superforms are intrinsic but there
        /// can be more than one per scalar.
        ///
        /// All of the superforms in this array have the same relationship
        /// to this declaration; the relationship type is a function of
        /// ``kinks`` and ``phylum``.
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
        /// If this symbol has been renamed, this points to the symbol referenced by the
        /// availability annotation.
        public
        var renamed:Int32?
        /// The address of a scalar that has documentation that is relevant,
        /// but less specific to this scalar.
        public
        var origin:Int32?

        public
        var _topics:[_Topic]

        @inlinable
        init(
            language:Phylum.Language,
            phylum:Phylum.Decl,
            kinks:Phylum.Decl.Kinks,
            route:Phylum.Decl.Route,
            path:UnqualifiedPath,
            signature:Signature<Int32> = .init(),
            location:SourceLocation<Int32>? = nil,
            article:Article? = nil,
            requirements:[Int32] = [],
            inhabitants:[Int32] = [],
            superforms:[Int32] = [],
            features:[Int32] = [],
            renamed:Int32? = nil,
            origin:Int32? = nil,
            _topics:[_Topic] = [])
        {
            self.language = language
            self.phylum = phylum
            self.kinks = kinks
            self.route = route
            self.path = path

            self.signature = signature
            self.location = location
            self.article = article

            self.requirements = requirements
            self.inhabitants = inhabitants
            self.superforms = superforms
            self.features = features
            self.renamed = renamed
            self.origin = origin

            self._topics = _topics
        }
    }
}
extension SymbolGraph.Decl
{
    @inlinable public
    init(language:Phylum.Language,
        phylum:Phylum.Decl,
        kinks:Phylum.Decl.Kinks,
        path:UnqualifiedPath)
    {
        self.init(language: language,
            phylum: phylum,
            kinks: kinks,
            route: .init(underscored: false, hashed: false),
            path: path)
    }
}
extension SymbolGraph.Decl
{
    /// See ``Phylum.Decl.scope(trimming:)``.
    @inlinable public
    var scope:[String]
    {
        self.phylum.scope(trimming: self.path)
    }
}
extension SymbolGraph.Decl
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        /// Deprecated.
        case flags_swift = "X"
        /// New in 0.8.12.
        case flags = "Y"
        case path = "P"

        case signature_availability = "V"
        case signature_abridged_bytecode = "B"
        case signature_expanded_bytecode = "E"
        case signature_expanded_scalars = "K"
        case signature_generics_constraints = "C"
        case signature_generics_parameters = "G"
        case signature_spis = "I"

        case requirements = "R"
        case inhabitants = "M"
        case superforms = "S"
        case features = "F"
        case renamed = "N"
        case origin = "O"

        case location = "L"
        case article = "A"
        case _topics = "T"
    }
}
extension SymbolGraph.Decl:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.flags] = Phylum.DeclFlags.init(
            language: self.language,
            phylum: self.phylum,
            kinks: self.kinks,
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

        /// Do *not* elide empty SPI arrays!
        bson[.signature_spis] = self.signature.spis

        bson[.requirements] = SymbolGraph.Buffer.init(elidingEmpty: self.requirements)
        bson[.inhabitants] = SymbolGraph.Buffer.init(elidingEmpty: self.inhabitants)
        bson[.superforms] = SymbolGraph.Buffer.init(elidingEmpty: self.superforms)
        bson[.features] = SymbolGraph.Buffer.init(elidingEmpty: self.features)

        bson[.renamed] = self.renamed
        bson[.origin] = self.origin

        bson[.location] = self.location
        bson[.article] = self.article
        bson[._topics] = self._topics.isEmpty ? nil : self._topics
    }
}
extension SymbolGraph.Decl:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        let flags:Phylum.DeclFlags = try bson[.flags]?.decode()
            ?? .swift(try bson[.flags_swift].decode())

        self.init(
            language: flags.language,
            phylum: flags.phylum,
            kinks: flags.kinks,
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
                    parameters: try bson[.signature_generics_parameters]?.decode() ?? []),
                spis: try bson[.signature_spis]?.decode()),

            location: try bson[.location]?.decode(),
            article: try bson[.article]?.decode(),
            requirements: try bson[.requirements]?.decode(as: SymbolGraph.Buffer.self,
                with: \.elements) ?? [],
            inhabitants: try bson[.inhabitants]?.decode(as: SymbolGraph.Buffer.self,
                with: \.elements) ?? [],
            superforms: try bson[.superforms]?.decode(as: SymbolGraph.Buffer.self,
                with: \.elements) ?? [],
            features: try bson[.features]?.decode(as: SymbolGraph.Buffer.self,
                with: \.elements) ?? [],
            renamed: try bson[.renamed]?.decode(),
            origin: try bson[.origin]?.decode(),
            _topics: try bson[._topics]?.decode() ?? [])
    }
}
