extension SPM.Build
{
    public
    enum Clean:Equatable, Hashable, Sendable
    {
        case artifacts
        case checkouts
    }
}
