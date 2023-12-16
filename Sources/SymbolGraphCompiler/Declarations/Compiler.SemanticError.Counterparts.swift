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
            lhs == rhs

        case    (.requirements, .requirements),
                (.scope, .scope):
            true

        case (_, _):
            false
        }
    }
}
