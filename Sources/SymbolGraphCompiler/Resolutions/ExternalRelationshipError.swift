import SymbolResolution

public
enum ExternalRelationshipError:Equatable, Error
{
    case conformer  (ScalarSymbolResolution, of:ScalarSymbolResolution)
    case membership (ScalarSymbolResolution, of:ScalarSymbolResolution)
    case member     (ScalarSymbolResolution, of:ScalarSymbolResolution)
}
extension ExternalRelationshipError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .conformer(let external, of: let conformance):
            return """
            Cannot declare conformance of external type '\(external)' to '\(conformance)' \
            without an associated extension block symbol.
            """
        
        case .membership(let external, of: let member):
            return """
            Cannot declare membership of '\(member)' in external symbol '\(external)'.
            """
        
        case .member(let external, of: let type):
            return """
            Cannot declare membership of external symbol '\(external)' in '\(type)' \
            without an associated extension block symbol.
            """
        }
    }
}
