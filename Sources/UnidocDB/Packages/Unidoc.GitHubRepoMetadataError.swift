import UnidocRecords

extension Unidoc
{
    @frozen @usableFromInline
    enum GitHubRepoMetadataError:Equatable, Error
    {
        case watchers

        case created(String)
        case updated(String)
        case pushed(String)
    }
}
extension Unidoc.GitHubRepoMetadataError:CustomStringConvertible
{
    @usableFromInline
    var description:String
    {
        switch self
        {
        case .watchers:             "repository metadata is missing field 'watchers'"
        case .created(let string):  "invalid timestamp '\(string)' for field 'created'"
        case .updated(let string):  "invalid timestamp '\(string)' for field 'updated'"
        case .pushed(let string):   "invalid timestamp '\(string)' for field 'pushed'"
        }
    }
}
