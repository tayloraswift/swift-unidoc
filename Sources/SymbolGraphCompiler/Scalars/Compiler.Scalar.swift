import Availability
import Declarations
import Fragments
import Generics
import LexicalPaths
import SourceMaps
import SymbolGraphParts

extension Compiler
{
    /// A scalar is the smallest “unit” a symbol can be broken down into.
    @frozen public
    struct Scalar
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
        var virtuality:ScalarPhylum.Virtuality?
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
        var superforms:[Symbol.Scalar]
        public internal(set)
        var origin:Symbol.Scalar?

        public internal(set)
        var comment:String

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
            self.origin = nil

            self.comment = ""
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
        
        if  let documentation:SymbolDescription.Documentation = description.documentation,
            let comment:String = context.filter(documentation: documentation)
        {
            self.comment = comment
        }
    }
}
