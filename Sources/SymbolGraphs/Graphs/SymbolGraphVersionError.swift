import SemanticVersions

@frozen public
enum SymbolGraphVersionError:Equatable, Error, Sendable
{
    case unsupported(SemanticVersion)
    case inconsistent([SemanticVersion])
}
extension SymbolGraphVersionError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .unsupported(let version):
            return "Symbol graph has unsupported format version '\(version)'."

        case .inconsistent(let versions):
            return "Symbol graph has inconsistent format versions \(versions)."
        }
    }
}

