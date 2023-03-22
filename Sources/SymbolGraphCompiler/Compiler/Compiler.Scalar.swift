extension Compiler
{
    struct Scalar
    {
        let conditions:[GenericConstraint<ScalarSymbolResolution>]

        private(set)
        var membership:ScalarSymbolResolution?

        init(conditions:[GenericConstraint<ScalarSymbolResolution>])
        {
            self.conditions = conditions
            self.membership = nil
        }
    }
}
extension Compiler.Scalar
{
    mutating
    func assign(
        membership:ScalarSymbolResolution) throws -> [GenericConstraint<ScalarSymbolResolution>]
    {
        switch self.membership
        {
        case nil, membership?:
            self.membership = membership
            return self.conditions
        
        case let other?:
            throw Compiler.MembershipConflictError.member(of: other, and: membership)
        }
    }
}
