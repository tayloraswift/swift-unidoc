extension Inliner.Groups
{
    enum Genericness:Equatable, Hashable, Comparable, Sendable
    {
        case generic
        case concrete
    }
}
