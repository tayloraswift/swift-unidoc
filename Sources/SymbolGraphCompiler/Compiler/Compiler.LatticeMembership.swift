extension Compiler
{
    enum LatticeMembership:Equatable, Hashable, Sendable
    {
        case requirement(of:ScalarSymbolResolution, optional:Bool = false)
        case member(of:ScalarSymbolResolution)
    }
}