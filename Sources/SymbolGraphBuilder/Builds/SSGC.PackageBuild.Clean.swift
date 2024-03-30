extension SSGC.PackageBuild
{
    public
    enum Clean:Equatable, Hashable, Sendable
    {
        case artifacts
        case checkouts
    }
}
