import SymbolGraphParts

extension Compiler.SemanticError
{
    public
    enum Counterparts:Sendable
    {
        case requirements
        case inhabitants
        case superforms(besides:(any SuperformRelationship.Type)? = nil)
        case scope
    }
}
