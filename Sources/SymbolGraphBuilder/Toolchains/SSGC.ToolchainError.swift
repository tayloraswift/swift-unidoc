import Symbols

extension SSGC
{
    public
    enum ToolchainError:Error, Equatable, Sendable
    {
        case malformedSwiftVersion
        case malformedSplash
        case malformedTriple
        case unsupportedTriple(Symbol.Triple)
    }
}
extension SSGC.ToolchainError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .malformedSwiftVersion:
            "Failed to parse 'swift --version' output (malformed version number)"
        case .malformedSplash:
            "Failed to parse 'swift --version' output (splash is clipped or malformed)"
        case .malformedTriple:
            "Failed to parse 'swift --version' output (malformed triple)"
        case .unsupportedTriple(let triple):
            "Unsupported triple '\(triple)'"
        }
    }
}
