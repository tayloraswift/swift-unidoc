/// A semver-based interpretation of a git ref name (branch or tag).
@frozen public
enum SemanticRef:Hashable, Equatable, Sendable
{
    case unstable(String)
    case version(SemanticVersion)
}
extension SemanticRef:CustomStringConvertible
{
    /// A *human-readable* description of this semantic ref name. This isn’t the
    /// same as its actual name (which is lost on parsing), and cannot be used to
    /// checkout a snapshot of the associated repository.
    public
    var description:String
    {
        switch self
        {
        case .version(let version): return "\(version) (stable)"
        case .unstable(let name):   return "\(name) (unstable)"
        }
    }
}
extension SemanticRef
{
    /// Returns the stable version formatted as a string, or the unstable tag name.
    ///
    /// Examples:
    /// -   `.version(.v(0, 1, 2))` → `0.1.2`
    /// -   `.unstable("0.1.2")` → `0.1.2`
    /// -   `.unstable("v0.1.2.3")` → `v0.1.2.3`
    @inlinable public
    var name:String
    {
        switch self
        {
        case .version(let version): return "\(version)"
        case .unstable(let name):   return name
        }
    }
    /// Interprets the given ref name by attempting to parse it as a semantic version.
    ///
    /// Examples:
    /// -   `0.1.2` → `.version(.v(0, 1, 2))`
    /// -   `v0.1.2` → `.version(.v(0, 1, 2))`
    /// -   `v0.1.2.3` → `.unstable("v0.1.2.3")`
    /// -   `v0.1` → `.version(.v(0, 1, 0))`
    /// -   `0.1` → `.version(.v(0, 1, 0))`
    @inlinable public static
    func infer(from name:String) -> Self
    {
        self.infer(from: name[...])
    }
    @inlinable public static
    func infer(from name:Substring) -> Self
    {
        SemanticVersion.init(tag: name).map(Self.version(_:)) ?? .unstable(String.init(name))
    }
}
