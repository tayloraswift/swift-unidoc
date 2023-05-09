import SemanticVersions

extension Repository
{
    /// A git reference.
    @frozen public
    enum Reference:Hashable, Equatable, Sendable
    {
        case version(SemanticVersion)
        case branch(String)
    }
}
extension Repository.Reference:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        switch self
        {
        case .version(let version): return version.description
        case .branch(let branch): return branch
        }
    }
}
