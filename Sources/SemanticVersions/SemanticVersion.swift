@frozen public
struct SemanticVersion:Equatable, Hashable, Sendable
{
    public
    var major:UInt16
    public
    var minor:UInt16
    public
    var patch:UInt16

    @inlinable internal
    init(major:UInt16, minor:UInt16, patch:UInt16)
    {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
}
extension SemanticVersion
{
    /// Creates a semantic version with the given components.
    @inlinable public static
    func v(_ major:UInt16, _ minor:UInt16, _ patch:UInt16) -> Self
    {
        self.init(major: major, minor: minor, patch: patch)
    }
}
extension SemanticVersion
{
    /// Attempts to parse a semantic version from a tag string, such as `1.2.3` or `v1.2.3`.
    @inlinable public
    init?(tag:String)
    {
        if  case "v"? = tag.first
        {
            self.init(tag.dropFirst())
        }
        else
        {
            self.init(tag)
        }
    }

    @inlinable internal
    init?(_ string:Substring)
    {
        let components:[Substring] = string.split(separator: ".", maxSplits: 2,
            omittingEmptySubsequences: false)
        if  components.count == 3,
            let major:UInt16 = .init(components[0]),
            let minor:UInt16 = .init(components[1]),
            let patch:UInt16 = .init(components[2])
        {
            self.init(major: major, minor: minor, patch: patch)
        }
        else
        {
            return nil
        }
    }
}
extension SemanticVersion:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        "\(self.major).\(self.minor).\(self.patch)"
    }
}
extension SemanticVersion:LosslessStringConvertible
{
    /// Attempts to parse a semantic version from a dot-separated triple, such as `1.2.3`.
    /// This initializer does not accept `v`-prefixed strings; use ``init(tag:)`` to accept
    /// an optional `v` prefix.
    @inlinable public
    init?(_ string:String)
    {
        self.init(string[...])
    }
}
extension SemanticVersion:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        (lhs.major, lhs.minor, lhs.patch) < (rhs.major, rhs.minor, rhs.patch)
    }
}
