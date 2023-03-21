import SymbolResolution

public
enum ExternalRelationshipError:Equatable, Error
{
    case conformer  (UnifiedScalarResolution, of:UnifiedScalarResolution)
    case membership (UnifiedScalarResolution, of:UnifiedScalarResolution)
    case member     (UnifiedScalarResolution, of:UnifiedSymbolResolution)
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
            Cannot declare membership of '\(member)' to external symbol '\(external)'.
            """
        
        case .member(let external, of: let type):
            return """
            Cannot declare membership in '\(type)' of external symbol '\(external)' \
            without an associated extension block symbol.
            """
        }
    }
}
