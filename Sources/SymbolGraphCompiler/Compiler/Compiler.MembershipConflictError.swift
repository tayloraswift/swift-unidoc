extension Compiler
{
    public
    enum MembershipConflictError:Equatable, Error
    {
        case feature(of:ScalarSymbolResolution, self:ScalarSymbolResolution)
        case member(of:ScalarSymbolResolution, and:ScalarSymbolResolution)
    }
}
