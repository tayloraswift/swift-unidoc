import SymbolResolution

public
enum SymbolRelationshipError:Equatable, Error
{
    case conformance(UnifiedSymbolResolution, of:UnifiedSymbolResolution)
    case conformer(UnifiedSymbolResolution, of:UnifiedSymbolResolution)

    case membership(UnifiedSymbolResolution, of:UnifiedSymbolResolution)
    case member(UnifiedSymbolResolution, of:UnifiedSymbolResolution)
}

