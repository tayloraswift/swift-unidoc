@frozen public
enum SemanticVersion:Equatable, Hashable, Sendable
{
    case release    (PatchVersion, build:String? = nil)
    case prerelease (PatchVersion, String, build:String? = nil)
}
extension SemanticVersion
{
    @inlinable public
    var patch:PatchVersion
    {
        switch self
        {
        case .release   (let version,    build: _): return version
        case .prerelease(let version, _, build: _): return version
        }
    }

    @available(*, deprecated, message: "use 'patch' or switch explicitly instead")
    @inlinable public
    var release:PatchVersion?
    {
        switch self
        {
        case .release(let version, _):  return version
        case .prerelease:               return nil
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
        case .release(let version, build: nil):
            return "\(version)"

        case .release(let version, build: let build?):
            return "\(version)+\(build)"

        case .prerelease(let version, let alpha, build: nil):
            return "\(version)-\(alpha)"

        case .prerelease(let version, let alpha, build: let build?):
            return "\(version)-\(alpha)+\(build)"
        }
    }
}
extension SemanticVersion:LosslessStringConvertible
{
    @inlinable public
    init?(_ string:some StringProtocol)
    {
        let patch:PatchVersion
        let alpha:String?
        let build:String?

        var i:String.Index = string.endIndex

        if  let plus:String.Index = string.lastIndex(of: "+")
        {
            build = .init(string[string.index(after: plus)...])
            i = plus
        }
        else
        {
            build = nil
        }

        if  let dash:String.Index = string[..<i].lastIndex(of: "-")
        {
            alpha = .init(string[string.index(after: dash) ..< i])
            i = dash
        }
        else
        {
            alpha = nil
        }

        if  let version:NumericVersion = .init(string[..<i])
        {
            patch = .init(padding: version)
        }
        else
        {
            return nil
        }

        if  let alpha:String
        {
            self = .prerelease(patch, alpha, build: build)
        }
        else
        {
            self = .release(patch, build: build)
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
