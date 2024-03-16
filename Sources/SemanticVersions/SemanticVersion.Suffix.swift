extension SemanticVersion
{
    @frozen public
    enum Suffix:Equatable, Hashable, Sendable
    {
        case release(build:String? = nil)
        case prerelease(String, build:String? = nil)
    }
}
extension SemanticVersion.Suffix:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        switch self
        {
        case .release(build: nil):
            return ""

        case .release(build: let build?):
            return "+\(build)"

        case .prerelease(let alpha, build: nil):
            return "-\(alpha)"

        case .prerelease(let alpha, build: let build?):
            return "-\(alpha)+\(build)"
        }
    }
}
extension SemanticVersion.Suffix:LosslessStringConvertible
{
    @inlinable public
    init(_ string:some StringProtocol)
    {
        var i:String.Index = string.endIndex
        self.init(string, index: &i)
    }
}
extension SemanticVersion.Suffix
{
    @inlinable
    init(_ string:some StringProtocol, index i:inout String.Index)
    {
        let alpha:String?
        let build:String?

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

        if  let alpha:String
        {
            self = .prerelease(alpha, build: build)
        }
        else
        {
            self = .release(build: build)
        }
    }
}