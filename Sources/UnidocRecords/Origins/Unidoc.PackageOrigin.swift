import Symbols

extension Unidoc
{
    @frozen public
    enum PackageOrigin:Equatable, Sendable
    {
        case github(GitHubOrigin)
    }
}
extension Unidoc.PackageOrigin
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

    /// Indicates whether the repository is alive. For GitHub repositories, this is true if the
    /// repository is neither ``GitHubOrigin/archived`` nor ``GitHubOrigin/disabled``.
    @inlinable public
    var alive:Bool
    {
        switch self
        {
        case .github(let self): !(self.archived || self.disabled)
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
}
