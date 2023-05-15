import PackageGraphs

extension Driver
{
    public
    enum ToolchainError:Error, Equatable, Sendable
    {
        case malformedSplash
        case malformedTriple
        case unsupportedTriple(Triple)
    }
}
extension Driver.ToolchainError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .malformedSplash:
            return "Failed to parse 'swift --version' output (splash is clipped or malformed)"
        case .malformedTriple:
            return "Failed to parse 'swift --version' output (malformed triple)"
        case .unsupportedTriple(let triple):
            return "Unsupported triple '\(triple)'"
        }
    }
}
