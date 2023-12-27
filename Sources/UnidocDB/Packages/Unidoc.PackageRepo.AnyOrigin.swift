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

    /// Returns the registrar’s short description for the repository.
    @inlinable public
    var about:String?
    {
        switch self
        {
        case .github(let self): self.about
        }
    }

    /// Returns the registrar’s name for the repository’s owner.
    @inlinable public
    var owner:String
    {
        switch self
        {
        case .github(let self): self.owner
        }
    }

    /// Returns the registrar’s name for the repository.
    @inlinable public
    var name:String
    {
        switch self
        {
        case .github(let self): self.name
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
