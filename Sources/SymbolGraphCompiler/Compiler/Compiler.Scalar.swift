import SymbolColonies

extension Compiler
{
    /// A scalar is the smallest “unit” a symbol can be broken down into.
    ///
    /// This is a reference type, because we want to be able to query
    /// things about the existence or knowledge of a scalar, and then
    /// separately write updates to the scalar without looking it up
    /// again.
    final
    class Scalar:Identifiable
    {
        final
        let phylum:ScalarPhylum

        //  Validation parameters, will not be encoded.
        final
        let resolution:ScalarSymbolResolution
        final
        let conditions:[GenericConstraint<ScalarSymbolResolution>]

        final
        let availability:SymbolAvailability
        final
        let generics:GenericSignature<ScalarSymbolResolution>
        final
        let location:SourceLocation<String>?
        final
        let path:LexicalPath

        /// The type this scalar is a member of. Membership is unique and
        /// intrinsic.
        final private(set)
        var membership:LatticeMembership?
        /// The scalar that this scalar implements, overrides, or inherits
        /// from. Superforms are unique and intrinsic.
        ///
        /// Only protocols can inherit from other protocols. (All other
        /// phyla can only conform to protocols.) Any class can inherit
        /// from another class.
        ///
        /// The compiler does not check for inheritance cycles.
        final private(set)
        var superform:LatticeSuperform?

        final private(set)
        var comment:String

        final private(set)
        var origin:ScalarSymbolResolution?

        private
        init(phylum:ScalarPhylum,
            resolution:ScalarSymbolResolution,
            conditions:[GenericConstraint<ScalarSymbolResolution>],
            availability:SymbolAvailability,
            generics:GenericSignature<ScalarSymbolResolution>,
            location:SourceLocation<String>?,
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
    convenience
    init(from description:SymbolDescription,
        as resolution:ScalarSymbolResolution,
        in culture:ModuleIdentifier) throws
    {
        guard let phylum:Compiler.ScalarPhylum = .init(description.phylum)
        else
        {
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
extension Compiler.Scalar
{
    final
    func assign(membership:Compiler.LatticeMembership,
        origin:ScalarSymbolResolution? = nil) throws
    {
        switch self.membership
        {
        case nil, membership?:
            self.membership = membership
        
        case let other?:
            throw Compiler.LatticeConflictError<Compiler.LatticeMembership>.init(
                existing: other)
        }
        if let origin:ScalarSymbolResolution
        {
            try self.assign(origin: origin)
        }
    }
    final
    func assign(superform:Compiler.LatticeSuperform,
        origin:ScalarSymbolResolution? = nil) throws
    {
        switch self.superform
        {
        case nil, superform?:
            self.superform = superform
        
        case let other?:
            throw Compiler.LatticeConflictError<Compiler.LatticeSuperform>.init(
                existing: other)
        }
        if let origin:ScalarSymbolResolution
        {
            try self.assign(origin: origin)
        }
    }
    final
    func assign(origin:ScalarSymbolResolution) throws
    {
        switch self.origin
        {
        case nil, origin?:
            self.origin = origin
        
        case let other?:
            throw Compiler.OriginConflictError.init(existing: other)
        }
    }
}
