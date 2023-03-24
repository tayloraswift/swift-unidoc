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
        
        private(set)
        var membership:ScalarSymbolResolution?

        init(resolution:ScalarSymbolResolution,
            conditions:[GenericConstraint<ScalarSymbolResolution>])
        {
            self.resolution = resolution
            self.conditions = conditions
            self.membership = nil
        }
    }
}
extension Compiler.Scalar
{
    func assign(membership:ScalarSymbolResolution) throws
    {
        switch self.membership
        {
        case nil, membership?:
            self.membership = membership
        
        case let other?:
            throw Compiler.MembershipConflictError.member(of: other)
        }
    }
}
