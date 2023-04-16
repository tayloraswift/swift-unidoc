import SymbolColonies

extension Compiler
{
    /// A scalar is the smallest “unit” a symbol can be broken down into.
    @frozen public
    struct Scalar
    {
        public
        let phylum:SymbolGraph.Scalar.Phylum

        //  Validation parameters, will not be encoded.
        public
        let resolution:ScalarSymbolResolution
        public
        let conditions:[GenericConstraint<ScalarSymbolResolution>]

        public
        let availability:SymbolAvailability
        public
        let generics:GenericSignature<ScalarSymbolResolution>
        //  TODO: trim file path prefixes
        public
        let location:SymbolDescription.Location?
        public
        let path:LexicalPath

        /// The type this scalar is a member of. Membership is unique and
        /// intrinsic.
        public
        var membership:LatticeMembership?
        /// The scalar that this scalar implements, overrides, or inherits
        /// from. Superforms are unique and intrinsic.
        ///
        /// Only protocols can inherit from other protocols. (All other
        /// phyla can only conform to protocols.) Any class can inherit
        /// from another class.
        ///
        /// The compiler does not check for inheritance cycles.
        public
        var superform:LatticeSuperform?

        public
        var comment:String

        public
        var origin:ScalarSymbolResolution?

        private
        init(phylum:SymbolGraph.Scalar.Phylum,
            resolution:ScalarSymbolResolution,
            conditions:[GenericConstraint<ScalarSymbolResolution>],
            availability:SymbolAvailability,
            generics:GenericSignature<ScalarSymbolResolution>,
            location:SymbolDescription.Location?,
            path:LexicalPath)
        {
            self.phylum = phylum

            self.resolution = resolution
            self.conditions = conditions

            self.availability = availability
            self.generics = generics
            self.location = location
            self.path = path

            self.membership = nil
            self.superform = nil

            self.comment = ""
            self.origin = nil
        }
    }
}
extension Compiler.Scalar
{
    init(from description:__shared SymbolDescription,
        as resolution:ScalarSymbolResolution,
        in culture:__shared ModuleIdentifier) throws
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

        self.init(phylum: phylum,
            resolution: resolution,
            conditions: description.extension.conditions,
            availability: description.availability,
            generics: description.generics,
            location: description.location,
            path: description.path)
        
        if  let documentation:SymbolDescription.Documentation = description.documentation
        {
            switch documentation.culture
            {
            case nil, culture?:
                self.comment = documentation.comment
            
            default:
                break
            }
        }
    }
}
