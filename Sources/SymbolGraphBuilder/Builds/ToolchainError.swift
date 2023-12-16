import SymbolGraphs

public
enum ToolchainError:Error, Equatable, Sendable
{
    case developmentSnapshotNotSupported
    case malformedSplash
    case malformedTriple
    case unsupportedTriple(Triple)
}
extension ToolchainError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .developmentSnapshotNotSupported:
            "Development snapshots are not supported"
        case .malformedSplash:
            "Failed to parse 'swift --version' output (splash is clipped or malformed)"
        case .malformedTriple:
            "Failed to parse 'swift --version' output (malformed triple)"
        case .unsupportedTriple(let triple):
            "Unsupported triple '\(triple)'"
        }
    }
}
