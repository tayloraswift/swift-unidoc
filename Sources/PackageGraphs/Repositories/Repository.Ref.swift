import SemanticVersions

extension Repository
{
    /// A git ref.
    @frozen public
    enum Ref:Hashable, Equatable, Sendable
    {
        case version(SemanticVersion)
        case branch(String)
    }
}
extension Repository.Ref:CustomStringConvertible
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
