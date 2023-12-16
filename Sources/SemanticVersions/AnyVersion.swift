/// A semver-based interpretation of a git ref name (branch or tag).
@frozen public
struct AnyVersion:Hashable, Equatable, Sendable
{
    public
    let canonical:Canonical

    @inlinable internal
    init(canonical:Canonical)
    {
        self.canonical = canonical
    }
}
extension AnyVersion
{
    @inlinable public static
    func stable(_ version:SemanticVersion) -> Self
    {
        .init(canonical: .stable(version))
    }

    @inlinable public
    var stable:SemanticVersion?
    {
        switch self.canonical
        {
        case .stable(let version):  version
        case .unstable:             nil
        }
    }

    @inlinable public
    var release:PatchVersion?
    {
        switch self.canonical
        {
        case .stable(.release(let version, build: _)):  version
        case _:                                         nil
        }
    }
}
extension AnyVersion:CustomStringConvertible
{
    /// Returns the stable version formatted as a string, or the unstable tag name.
    ///
    /// Examples:
    /// -   `.stable(.release(.v(0, 1, 2)))` → `0.1.2`
    /// -   `.unstable("0.1.2")` → `0.1.2`
    /// -   `.unstable("v0.1.2.3")` → `v0.1.2.3`
    @inlinable public
    var description:String
    {
        switch self.canonical
        {
        case .stable(let version):  "\(version)"
        case .unstable(let name):   name
        }
    }
}
extension AnyVersion:LosslessStringConvertible
{
    /// Attempts to parse a semantic version from a tag string, such as `1.2.3` or
    /// `v1.2.3`. If the tag string has at least one, but fewer than three components,
    /// the semantic version is zero-extended.
    ///
    /// Examples:
    /// -   `0.1.2` → `.stable(.release(.v(0, 1, 2)))`
    /// -   `v0.1.2` → `.stable(.release(.v(0, 1, 2)))`
    /// -   `v0.1.2.3` → `.unstable("v0.1.2.3")`
    /// -   `v0.1` → `.stable(.release(.v(0, 1, 0)))`
    /// -   `0.1` → `.stable(.release(.v(0, 1, 0)))`
    /// -   `1` → `.stable(.release(.v(1, 0, 0)))`
    ///
    /// Although git tags are case sensitive, ``AnyVersion`` is not.
    ///
    /// Examples:
    /// -   `master` → `.unstable("master")`
    /// -   `Master` → `.unstable("master")`
    /// -   `MASTER` → `.unstable("master")`
    @inlinable public
    init(_ refname:some StringProtocol)
    {
        if  let semantic:SemanticVersion = .init(refname: refname)
        {
            self.init(canonical: .stable(semantic))
        }
        else
        {
            self.init(canonical: .unstable(refname.lowercased()))
        }
    }
}
extension AnyVersion:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral:String)
    {
        self.init(stringLiteral)
    }
}
