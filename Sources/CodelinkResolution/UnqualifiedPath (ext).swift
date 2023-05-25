import ModuleGraphs
import LexicalPaths

extension UnqualifiedPath
{
    @inlinable public static
    func / (lhs:String, rhs:UnqualifiedPath) -> QualifiedPath
    {
        .init(lhs, rhs)
    }
}
