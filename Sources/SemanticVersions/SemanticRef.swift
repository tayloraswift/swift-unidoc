/// A semver-based interpretation of a git ref name (branch or tag).
@frozen public
enum SemanticRef:Hashable, Equatable, Sendable
{
    case unstable(String)
    case version(SemanticVersion)
}
extension SemanticRef
{
    /// Interprets the given ref name by attempting to parse it as a semantic version.
    ///
    /// Examples:
    /// -   `0.1.2` → `.version(.v(0, 1, 2))`
    /// -   `v0.1.2` → `.version(.v(0, 1, 2))`
    /// -   `v0.1.2.3` → `.unstable("v0.1.2.3")`
    /// -   `v0.1` → `.unstable("v0.1")`
    @inlinable public static
    func infer(from name:String) -> Self
    {
        SemanticVersion.init(tag: name).map(Self.version(_:)) ?? .unstable(name)
    }
}
