import Symbols

extension Unidoc.PackageRepo
{
    @frozen public
    enum AnyOrigin:Equatable, Sendable
    {
        case github(GitHubOrigin)
    }
}
extension Unidoc.PackageRepo.AnyOrigin
{
    @inlinable public
    var https:String
    {
        switch self
        {
        case .github(let self): self.https
        }
    }

    @inlinable public
    func blob(refname:String, file:Symbol.File) -> String
    {
        switch self
        {
        case .github(let self): "\(self.https)/blob/\(refname)/\(file)"
        }
    }
}
