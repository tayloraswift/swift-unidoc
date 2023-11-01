import Codelinks
import LexicalPaths
import ModuleGraphs
import Unidoc

@frozen public
struct CodelinkResolver<Scalar> where Scalar:Hashable
{
    public
    let table:Table
    public
    let scope:Scope

    @inlinable public
    init(table:Table, scope:Scope)
    {
        self.table = table
        self.scope = scope
    }
}
extension CodelinkResolver
{
    @_specialize(where Scalar == Int32)
    @_specialize(where Scalar == Unidoc.Scalar)
    public
    func resolve(_ link:Codelink) -> Overloads
    {
        switch link.base
        {
        case .relative:
            for index:Int in
                (self.scope.path.startIndex ... self.scope.path.endIndex).reversed()
            {
                let overloads:Overloads = self.table.query(
                    qualified: ["\(self.scope.namespace)"]
                        + self.scope.path[..<index]
                        + link.path.components,
                    suffix: link.suffix)

                guard overloads.isEmpty
                else
                {
                    return overloads
                }
            }
            for namespace:ModuleIdentifier in self.scope.imports where
                namespace != self.scope.namespace
            {
                let overloads:Overloads = self.table.query(
                    qualified: ["\(namespace)"] + link.path.components,
                    suffix: link.suffix)

                guard overloads.isEmpty
                else
                {
                    return overloads
                }
            }

            fallthrough

        case .qualified:
            return self.table.query(qualified: link.path.components, suffix: link.suffix)
        }

    }
}
