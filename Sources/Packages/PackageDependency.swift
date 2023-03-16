@frozen public
enum PackageDependency:Equatable, Sendable
{
    case filesystem(Filesystem)
    case resolvable(Resolvable)
}
