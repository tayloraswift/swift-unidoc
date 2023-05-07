extension SystemProcessError
{
    public
    enum Operation:Equatable, Sendable
    {
        case posix_spawnp
        case waitpid
    }
}
