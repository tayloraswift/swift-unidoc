extension Compiler
{
    public
    enum MembershipConflictError:Equatable, Error
    {
        case feature(of:ScalarSymbolResolution)
        case member(of:ScalarSymbolResolution)
    }
}
