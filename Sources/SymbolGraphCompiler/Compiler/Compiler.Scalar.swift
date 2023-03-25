import SymbolColonies

extension Compiler
{
    /// A scalar is the smallest “unit” a symbol can be broken down into.
    ///
    /// This is a reference type, because we want to be able to query
    /// things about the existence or knowledge of a scalar, and then
    /// separately write updates to the scalar without looking it up
    /// again.
    class Scalar:Identifiable
    {
        class
        var phylum:SymbolPhylum { .typealias }

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
        let path:SymbolPath

        /// The type this scalar is a member of. Membership is unique and
        /// intrinsic.
        final private(set)
        var membership:LatticeMembership?
        /// The type this scalar inherits from. Inheritance is unique and
        /// intrinsic.
        ///
        /// Only protocols can inherit from other protocols. (All other
        /// phyla can only conform to protocols.) Any class can inherit
        /// from another class.
        ///
        /// The compiler does not check for inheritance cycles.
        final private(set)
        var superform:LatticeSuperform?

        private
        init(resolution:ScalarSymbolResolution,
            conditions:[GenericConstraint<ScalarSymbolResolution>],
            availability:SymbolAvailability,
            generics:GenericSignature<ScalarSymbolResolution>,
            location:SourceLocation<String>?,
            path:SymbolPath)
        {
            self.resolution = resolution
            self.conditions = conditions

            self.availability = availability
            self.generics = generics
            self.location = location
            self.path = path
            
            self.membership = nil
            self.superform = nil
        }
    }
}
extension Compiler.Scalar
{
    private convenience
    init(from description:SymbolDescription, as resolution:ScalarSymbolResolution)
    {
        self.init(resolution: resolution,
            conditions: description.extension.conditions,
            availability: description.availability,
            generics: description.generics,
            location: description.location,
            path: description.path)
    }
    static
    func infer(from description:SymbolDescription,
        as resolution:ScalarSymbolResolution) throws -> Compiler.Scalar
    {
        switch description.phylum
        {
        case .actor:
            return Compiler.Actor.init(from: description, as: resolution)
        case .associatedtype:
            return Compiler.AssociatedType.init(from: description, as: resolution)
        case .case:
            return Compiler.EnumCase.init(from: description, as: resolution)
        case .class:
            return Compiler.Class.init(from: description, as: resolution)
        case .deinitializer:
            return Compiler.Deinit.init(from: description, as: resolution)
        case .enum:
            return Compiler.Enum.init(from: description, as: resolution)
        case .func:
            return Compiler.GlobalFunc.init(from: description, as: resolution)
        case .initializer:
            return Compiler.Init.init(from: description, as: resolution)
        case .instanceMethod:
            return Compiler.InstanceMethod.init(from: description, as: resolution)
        case .instanceProperty:
            return Compiler.InstanceProperty.init(from: description, as: resolution)
        case .instanceSubscript:
            return Compiler.InstanceSubscript.init(from: description, as: resolution)
        case .operator:
            return Compiler.GlobalOperator.init(from: description, as: resolution)
        case .protocol:
            return Compiler.ProtocolScalar.init(from: description, as: resolution)
        case .struct:
            return Compiler.Struct.init(from: description, as: resolution)
        case .typealias:
            return Compiler.Typealias.init(from: description, as: resolution)
        case .typeMethod:
            return Compiler.StaticMethod.init(from: description, as: resolution)
        case .typeOperator:
            return Compiler.StaticOperator.init(from: description, as: resolution)
        case .typeProperty:
            return Compiler.StaticProperty.init(from: description, as: resolution)
        case .typeSubscript:
            return Compiler.StaticSubscript.init(from: description, as: resolution)
        case .var:
            return Compiler.GlobalVar.init(from: description, as: resolution)
        
        case .extension:
            throw Compiler.ScalarPhylumError.unsupported(.extension)
        case .macro:
            throw Compiler.ScalarPhylumError.unsupported(.macro)
        }
    }
}
extension Compiler.Scalar
{
    final
    func assign(membership:Compiler.LatticeMembership) throws
    {
        switch self.membership
        {
        case nil, membership?:
            self.membership = membership
        
        case let other?:
            throw Compiler.LatticeConflictError<Compiler.LatticeMembership>.init(
                existing: other)
        }
    }
    
    final
    func assign(superform:Compiler.LatticeSuperform) throws
    {
        switch self.superform
        {
        case nil, superform?:
            self.superform = superform
        
        case let other?:
            throw Compiler.LatticeConflictError<Compiler.LatticeSuperform>.init(
                existing: other)
        }
    }
}
