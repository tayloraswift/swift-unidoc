import SymbolColonies

public
enum SymbolRelationshipError:Equatable, Error
{
    case source(of:SymbolRelationship)
    case target(of:SymbolRelationship)
}
