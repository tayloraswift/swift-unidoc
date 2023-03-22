import SymbolColonies

public
enum SymbolRelationshipError:Equatable, Error
{
    case conformer(SymbolRelationship.Conformance)

    case membership(SymbolRelationship.Membership)
    case member(SymbolRelationship.Membership)
}

