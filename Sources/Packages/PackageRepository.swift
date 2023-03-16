@frozen public
enum PackageRepository:Hashable, Equatable, Sendable
{
    /// A package in a local git repository.
    case local(file:PackageRoot)
    /// A package in a remote git repository.
    case remote(url:String)
}
