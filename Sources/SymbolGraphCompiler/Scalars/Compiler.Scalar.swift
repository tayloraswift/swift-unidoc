import Availability
import Declarations
import Generics
import LexicalPaths
import SourceMaps
import SymbolGraphParts

extension Compiler
{
    /// A scalar is the smallest “unit” a symbol can be broken down into.
    @frozen public
    struct Scalar:Sendable
    {
        public
        let declaration:Declaration<Symbol.Scalar>
        public
        let resolution:Symbol.Scalar
        public
        let location:SourceLocation<FileIdentifier>?

        public
        let phylum:ScalarPhylum
        public
        let path:LexicalPath

        public internal(set)
        var virtuality:ScalarVirtuality?
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
        var superforms:Set<Symbol.Scalar>
        /// The *unqualified* features inherited by this scalar. Avoid adding
        /// features here; if the feature’s extension constraints are known,
        /// add them to an appropriate ``ExtensionReference`` instead.
        ///
        /// This field only exists because of an upstream bug in SymbolGraphGen.
        public internal(set)
        var features:Set<Symbol.Scalar>
        public internal(set)
        var origin:Symbol.Scalar?

        private
        var comment:Documentation.Comment?

        private
        init(declaration:Declaration<Symbol.Scalar>,
            resolution:Symbol.Scalar,
            visibility:SymbolDescription.Visibility,
            location:SourceLocation<FileIdentifier>?,
            phylum:ScalarPhylum,
            path:LexicalPath)
        {
            self.declaration = declaration
            self.resolution = resolution
            self.location = location
            self.phylum = phylum
            self.path = path

            self.virtuality = visibility == .open ? .open : nil
            self.superforms = []
            self.features = []
            self.origin = nil

            self.comment = nil
        }
    }
}
extension Compiler.Scalar:Identifiable
{
    @inlinable public
    var id:ScalarIdentifier
    {
        self.resolution.id
    }

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
        as resolution:__owned Symbol.Scalar,
        in context:__shared Compiler.SourceContext) throws
    {
        guard case .scalar(let phylum) = description.phylum
        else
        {
            throw Compiler.SymbolError.init(invalid: .scalar(resolution))
        }

        self.init(declaration: description.declaration,
            resolution: resolution,
            visibility: description.visibility,
            location: try description.location?.map(context.resolve(uri:)),
            phylum: phylum,
            path: description.path)
        
        if  let doccomment:SymbolDescription.Doccomment = description.doccomment
        {
            self.comment = context.filter(doccomment: doccomment)
        }
    }
}
