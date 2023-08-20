import SymbolGraphParts

extension Compiler.SemanticError
{
    public
    enum Counterparts:Sendable
    {
        case requirements
        case superforms(besides:(any SuperformRelationship.Type)? = nil)
        case scope
    }
}
extension Compiler.SemanticError.Counterparts:Equatable
{
    public static
    func == (lhs:Self, rhs:Self) -> Bool
    {
        switch (lhs, rhs)
        {
        case    (.superforms(besides: let lhs), .superforms(besides: let rhs)):
            return lhs == rhs

        case    (.requirements, .requirements),
                (.scope, .scope):
            return true

        case (_, _):
            return false
        }
    }
}
