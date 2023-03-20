extension Compiler
{
    struct Scalar
    {
        let conditions:[GenericConstraint<SymbolIdentifier>]

        private(set)
        var membership:SymbolIdentifier?

        init(conditions:[GenericConstraint<SymbolIdentifier>])
        {
            self.conditions = conditions
            self.membership = nil
        }
    }
}
extension Compiler.Scalar
{
    mutating
    func assign(membership:SymbolIdentifier) throws -> [GenericConstraint<SymbolIdentifier>]
    {
        switch self.membership
        {
        case nil, membership?:
            self.membership = membership
            return self.conditions
        
        case let other?:
            throw SymbolMembershipError.multiple(other, membership)
        }
    }
}
