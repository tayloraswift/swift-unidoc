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
        let resolution:ScalarSymbolResolution
        let conditions:[GenericConstraint<ScalarSymbolResolution>]
        
        /// The type this scalar is a member of. Membership is unique and
        /// intrinsic.
        private(set)
        var membership:LatticeMembership?
        /// The type this scalar inherits from. Inheritance is unique and
        /// intrinsic.
        ///
        /// Only protocols can inherit from other protocols. (All other
        /// phyla can only conform to protocols.) Any class can inherit
        /// from another class.
        ///
        /// The compiler does not check for inheritance
        /// cycles.
        private(set)
        var superform:LatticeSuperform?

        init(resolution:ScalarSymbolResolution,
            conditions:[GenericConstraint<ScalarSymbolResolution>])
        {
            self.resolution = resolution
            self.conditions = conditions
            self.membership = nil
            self.superform = nil
        }
    }
}
extension Compiler.Scalar
{
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
