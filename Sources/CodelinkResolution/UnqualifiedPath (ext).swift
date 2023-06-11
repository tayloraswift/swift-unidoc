import ModuleGraphs
import LexicalPaths

extension UnqualifiedPath
{
    @inlinable public static
    func / (lhs:ModuleIdentifier, rhs:UnqualifiedPath) -> QualifiedPath
    {
        .init("\(lhs)", rhs)
    }
}
