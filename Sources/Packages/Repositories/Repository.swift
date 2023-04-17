@available(*, deprecated, renamed: "Repository")
public
typealias PackageRepository = Repository

@frozen public
enum Repository:Hashable, Equatable, Sendable
{
    /// A package in a local git repository.
    case local(root:Root)
    /// A package in a remote git repository.
    case remote(url:String)
}
