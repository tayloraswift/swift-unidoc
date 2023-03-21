import SymbolResolution

public
enum ExtensionBlockRelationshipError:Equatable, Error
{
    case target(extension:ExtensionBlockResolution, of:UnifiedSymbolResolution)
    case source(extension:UnifiedSymbolResolution, of:UnifiedSymbolResolution)
}
