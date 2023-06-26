import Availability
import Declarations
import Generics
import LexicalPaths
import Sources
import Symbols
import SymbolGraphParts
import SymbolGraphs
import Unidoc

extension Compiler
{
    /// A scalar is the smallest “unit” a symbol can be broken down into.
    @_eagerMove
    @frozen public
    struct Decl:Identifiable, Sendable
    {
        public
        let id:Symbol.Decl

        public
        let declaration:Declaration<Symbol.Decl>
        public
        let location:SourceLocation<Symbol.File>?

        public
        let phylum:Unidoc.Decl
        public
        let path:UnqualifiedPath

        public internal(set)
        var aperture:Unidoc.Decl.Aperture
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

        public private(set)
        var comment:Doccomment?

        private
        init(_ id:Symbol.Decl,
            declaration:Declaration<Symbol.Decl>,
            visibility:SymbolDescription.Visibility,
            location:SourceLocation<Symbol.File>?,
            phylum:Unidoc.Decl,
            path:UnqualifiedPath)
        {
            self.id = id

            self.declaration = declaration
            self.location = location
            self.phylum = phylum
            self.path = path

            self.aperture = visibility == .open ? .open : .closed

            self.superforms = []
            self.features = []
            self.origin = nil

            self.comment = nil
        }
    }
}
extension Compiler.Decl
{
    init(from description:__shared SymbolDescription,
        as resolution:__owned Symbol.Decl,
        in culture:__shared Compiler.Culture) throws
    {
        guard case .decl(let phylum) = description.phylum
        else
        {
            throw Compiler.UnexpectedSymbolError.scalar(resolution)
        }

        self.init(resolution,
            declaration: description.declaration,
            visibility: description.visibility,
            location: try description.location?.map(culture.resolve(uri:)),
            phylum: phylum,
            path: description.path)

        if  let doccomment:SymbolDescription.Doccomment = description.doccomment
        {
            self.comment = culture.filter(doccomment: doccomment)
        }
    }
}
