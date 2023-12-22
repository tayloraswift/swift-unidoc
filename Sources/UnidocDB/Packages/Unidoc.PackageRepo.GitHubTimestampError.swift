extension Unidoc.PackageRepo
{
    @frozen @usableFromInline
    enum GitHubTimestampError:Equatable, Error
    {
        case created(String)
        case updated(String)
        case pushed(String)
    }
}
extension Unidoc.PackageRepo.GitHubTimestampError:CustomStringConvertible
{
    @usableFromInline
    var description:String
    {
        switch self
        {
        case .created(let string):  "invalid timestamp '\(string)' for field 'created'"
        case .updated(let string):  "invalid timestamp '\(string)' for field 'updated'"
        case .pushed(let string):   "invalid timestamp '\(string)' for field 'pushed'"
        }
    }
}
