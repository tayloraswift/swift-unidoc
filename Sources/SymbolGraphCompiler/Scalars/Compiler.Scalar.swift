import SymbolDescriptions

extension Compiler
{
    /// A scalar is the smallest “unit” a symbol can be broken down into.
    @frozen public
    struct Scalar
    {
        public internal(set)
        var virtuality:SymbolGraph.Scalar.Virtuality?
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
        var superforms:[ScalarSymbolResolution]
        public internal(set)
        var origin:ScalarSymbolResolution?

        public internal(set)
        var comment:String

        public
        let availability:SymbolAvailability
        public
        let fragments:Declaration<ScalarSymbolResolution>
        public
        let generics:GenericSignature<ScalarSymbolResolution>
        //  TODO: trim file path prefixes
        public
        let location:SourceLocation<FileIdentifier>?
        public
        let path:LexicalPath
        public
        let phylum:SymbolGraph.Scalar.Phylum
        public
        let resolution:ScalarSymbolResolution

        private
        init(resolution:ScalarSymbolResolution,
            availability:SymbolAvailability,
            visibility:SymbolDescription.Visibility,
            fragments:Declaration<ScalarSymbolResolution>,
            generics:GenericSignature<ScalarSymbolResolution>,
            location:SourceLocation<FileIdentifier>?,
            path:LexicalPath,
            phylum:SymbolGraph.Scalar.Phylum)
        {
            self.virtuality = visibility == .open ? .open : nil
            self.superforms = []
            self.origin = nil

            self.comment = ""

            self.availability = availability
            self.fragments = fragments
            self.generics = generics
            self.location = location
            self.path = path
            self.phylum = phylum
            self.resolution = resolution
        }
    }
}
extension Compiler.Scalar
{
    init(from description:__shared SymbolDescription,
        as resolution:__owned ScalarSymbolResolution,
        in context:__shared Compiler.SourceContext) throws
    {
        let phylum:SymbolGraph.Scalar.Phylum
        switch description.phylum
        {
        case .actor:                        phylum = .actor
        case .associatedtype:               phylum = .associatedtype
        case .case:                         phylum = .case
        case .class:                        phylum = .class
        case .deinitializer:                phylum = .deinitializer
        case .enum:                         phylum = .enum
        case .func(let objectivity):        phylum = .func(objectivity)
        case .initializer:                  phylum = .initializer
        case .protocol:                     phylum = .protocol
        case .subscript(let objectivity):   phylum = .subscript(objectivity)
        case .operator:                     phylum = .operator
        case .struct:                       phylum = .struct
        case .typealias:                    phylum = .typealias
        case .var(let objectivity):         phylum = .var(objectivity)
        case .extension, .macro:
            throw Compiler.PhylumError.unsupported(description.phylum)
        }

        self.init(resolution: resolution,
            availability: description.availability,
            visibility: description.visibility,
            fragments: description.fragments,
            generics: description.generics,
            location: try description.location?.map(context.resolve(uri:)),
            path: description.path,
            phylum: phylum)
        
        if  let documentation:SymbolDescription.Documentation = description.documentation,
            let comment:String = context.filter(documentation: documentation)
        {
            self.comment = comment
        }
    }
}
