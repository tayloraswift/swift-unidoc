import Availability
import LexicalPaths
import Signatures
import Sources
import SymbolGraphParts
import Symbols

extension SSGC
{
    /// A scalar is the smallest “unit” a symbol can be broken down into.
    @_eagerMove
    @frozen public
    struct Decl:Identifiable, Sendable
    {
        public
        let id:Symbol.Decl

        public
        let signature:Signature<Symbol.Decl>
        public
        let location:SourceLocation<Symbol.File>?

        public
        let language:Phylum.Language
        public
        let phylum:Phylum.Decl
        public
        let path:UnqualifiedPath

        /// Protocol requirements.
        public internal(set)
        var requirements:Set<Symbol.Decl>

        /// Enumeration cases.
        public internal(set)
        var inhabitants:Set<Symbol.Decl>

        /// The scalars that this scalar implements, overrides, or inherits
        /// from. Superforms are intrinsic but there can be more than one
        /// per scalar.
        ///
        /// Only protocols can inherit from other protocols. (All other
        /// phyla can only conform to protocols.) Any class can inherit
        /// from another class.
        ///
        /// The compiler does not check for inheritance cycles.
        public internal(set)
        var superforms:Set<Symbol.Decl>
        /// The *unqualified* features inherited by this scalar. Avoid adding
        /// features here; if the feature’s extension constraints are known,
        /// add them to an appropriate ``ExtensionObject`` instead.
        ///
        /// This field only exists because of an upstream bug in SymbolGraphGen.
        public internal(set)
        var features:Set<Symbol.Decl>
        /// A scalar that has documentation that is relevant, but less specific
        /// to this scalar.
        public internal(set)
        var origin:Symbol.Decl?
        public internal(set)
        var kinks:Phylum.Decl.Kinks

        public private(set)
        var comment:DocumentationComment?


        private
        init(_ id:Symbol.Decl,
            signature:Signature<Symbol.Decl>,
            location:SourceLocation<Symbol.File>?,
            language:Phylum.Language,
            phylum:Phylum.Decl,
            path:UnqualifiedPath)
        {
            self.id = id

            self.signature = signature
            self.location = location
            self.language = language
            self.phylum = phylum
            self.path = path

            self.requirements = []
            self.inhabitants = []
            self.superforms = []
            self.features = []
            self.origin = nil
            self.kinks = []

            self.comment = nil
        }
    }
}
extension SSGC.Decl
{
    init(from vertex:__shared /* borrowing */ SymbolGraphPart.Vertex,
        as symbol:/* consuming */ Symbol.Decl,
        in culture:__shared /* borrowing */ SSGC.TypeChecker.Culture) throws
    {
        guard case .decl(let phylum) = vertex.phylum
        else
        {
            throw SSGC.UnexpectedSymbolError.scalar(symbol)
        }

        let language:Phylum.Language
        if  case .swift = culture.language,
            case .c = symbol.language
        {
            language = .c
        }
        else
        {
            language = culture.language
        }

        self.init(symbol,
            signature: vertex.signature,
            location: try vertex.location?.map(culture.resolve(uri:)),
            language: language,
            phylum: phylum,
            path: vertex.path)

        //  It’s not like we should ever see a vertex that is both `final` and `open`, but who
        //  knows what bugs exist in lib/SymbolGraphGen.
        if  vertex.final
        {
            self.kinks[is: .final] = true
        }
        else if
            case .open = vertex.acl
        {
            self.kinks[is: .open] = true
        }

        if  let doccomment:SymbolGraphPart.Vertex.Doccomment = vertex.doccomment
        {
            self.comment = culture.filter(doccomment: doccomment)
        }
    }
}
