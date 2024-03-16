@frozen public
struct SemanticVersion:Equatable, Hashable, Sendable
{
    public
    var number:PatchVersion
    public
    var suffix:Suffix

    @inlinable
    init(number:PatchVersion, suffix:Suffix)
    {
        self.number = number
        self.suffix = suffix
    }
}
extension SemanticVersion
{
    @inlinable public static
    func release(_ number:PatchVersion, build:String? = nil) -> Self
    {
        .init(number: number, suffix: .release(build: build))
    }

    @inlinable public static
    func prerelease(_ number:PatchVersion, _ alpha:String, build:String? = nil) -> Self
    {
        .init(number: number, suffix: .prerelease(alpha, build: build))
    }
}
extension SemanticVersion
{
    /// Returns true if this is a release version, false if it is a prerelease.
    @inlinable public
    var release:Bool
    {
        switch self.suffix
        {
        case .release:      true
        case .prerelease:   false
        }
    }
}
extension SemanticVersion:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        switch self.suffix
        {
        case .release(build: nil):
            "\(self.number)"

        case .release(build: let build?):
            "\(self.number)+\(build)"

        case .prerelease(let alpha, build: nil):
            "\(self.number)-\(alpha)"

        case .prerelease(let alpha, build: let build?):
            "\(self.number)-\(alpha)+\(build)"
        }
    }
}
extension SemanticVersion:LosslessStringConvertible
{
    @inlinable public
    init?(_ string:some StringProtocol)
    {
        let number:PatchVersion
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
            number = .init(padding: version)
        }
        else
        {
            return nil
        }

        if  let alpha:String
        {
            self.init(number: number, suffix: .prerelease(alpha, build: build))
        }
        else
        {
            self.init(number: number, suffix: .release(build: build))
        }
    }
}
// extension SemanticVersion:RawRepresentable
// {
//     @inlinable public
//     var rawValue:String
//     {
//         self.description
//     }
//     @inlinable public
//     init?(rawValue:String)
//     {
//         self.init(rawValue)
//     }
// }
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
