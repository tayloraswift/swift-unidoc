import Availability
import Declarations
import Generics
import LexicalPaths
import Sources
import Symbols
import SymbolGraphParts

extension Compiler
{
    /// A scalar is the smallest “unit” a symbol can be broken down into.
    @_eagerMove
    @frozen public
    struct Scalar:Sendable
    {
        public
        let id:ScalarSymbol

        public
        let declaration:Declaration<ScalarSymbol>
        public
        let location:SourceLocation<FileSymbol>?

        public
        let phylum:ScalarPhylum
        public
        let path:UnqualifiedPath

        public internal(set)
        var aperture:ScalarAperture
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
        var superforms:Set<ScalarSymbol>
        /// The *unqualified* features inherited by this scalar. Avoid adding
        /// features here; if the feature’s extension constraints are known,
        /// add them to an appropriate ``ExtensionObject`` instead.
        ///
        /// This field only exists because of an upstream bug in SymbolGraphGen.
        public internal(set)
        var features:Set<ScalarSymbol>
        /// A scalar that has documentation that is relevant, but less specific
        /// to this scalar.
        public internal(set)
        var origin:ScalarSymbol?

        private
        var comment:Documentation.Comment?

        private
        init(_ id:ScalarSymbol,
            declaration:Declaration<ScalarSymbol>,
            visibility:SymbolDescription.Visibility,
            location:SourceLocation<FileSymbol>?,
            phylum:ScalarPhylum,
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
extension Compiler.Scalar:Identifiable
{
    public
    var documentation:Compiler.Documentation?
    {
        self.comment.map
        {
            let scope:[String]
            switch self.phylum
            {
            case    .actor,
                    .class,
                    .enum,
                    .protocol,
                    .struct:
                scope = self.path.map { $0 }

            case    .associatedtype,
                    .case,
                    .deinitializer,
                    .func,
                    .initializer,
                    .operator,
                    .subscript,
                    .typealias,
                    .var:
                scope = self.path.prefix
            }

            return .init(comment: $0, scope: scope)
        }
    }
}
extension Compiler.Scalar
{
    init(from description:__shared SymbolDescription,
        as resolution:__owned ScalarSymbol,
        in culture:__shared Compiler.Culture) throws
    {
        guard case .scalar(let phylum) = description.phylum
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
