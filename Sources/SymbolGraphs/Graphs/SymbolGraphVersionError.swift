import SemanticVersion

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
            return "Symbolgraph has unsupported format version '\(version)'."
        
        case .inconsistent(let versions):
            return "Symbolgraph has inconsistent format versions \(versions)."
        }
    }
}

