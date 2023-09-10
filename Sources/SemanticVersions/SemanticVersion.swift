@frozen public
enum SemanticVersion:Equatable, Hashable, Comparable, Sendable
{
    case release(PatchVersion)

    @available(*, unavailable, message: "unimplemented")
    case prerelease
}
extension SemanticVersion
{
    @inlinable public
    var release:PatchVersion?
    {
        switch self
        {
        case .release(let version): return version
        case .prerelease:           return nil
        }
    }
}
extension SemanticVersion:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        switch self
        {
        case .release(let version): return "\(version)"
        }
    }
}
extension SemanticVersion:LosslessStringConvertible
{
    @inlinable public
    init?(_ string:some StringProtocol)
    {
        if  let version:NumericVersion = .init(string)
        {
            self = .release(.init(padding: version))
        }
        else
        {
            return nil
        }
    }
}
extension SemanticVersion:RawRepresentable
{
    @inlinable public
    var rawValue:String
    {
        self.description
    }
    @inlinable public
    init?(rawValue:String)
    {
        self.init(rawValue)
    }
}
extension SemanticVersion
{
    /// Attempts to parse a semantic version from a tag string, such as `1.2.3` or
    /// `v1.2.3`. If the tag string has at least one, but fewer than three components,
    /// the semantic version is zero-extended.
    @inlinable public
    init?(refname:some StringProtocol)
    {
        if case "v"? = refname.first
        {
            self.init(refname.dropFirst())
        }
        else
        {
            self.init(refname)
        }
    }
}
