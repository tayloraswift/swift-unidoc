import Codelinks
import LexicalPaths
import ModuleGraphs
import SymbolGraphs

@frozen public
struct CodelinkResolver<Address> where Address:Hashable
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
    @_specialize(where Address == Int32)
    @_specialize(where Address == GlobalAddress)
    public
    func resolve(_ link:Codelink) -> Overloads
    {
        for index:Int in (self.scope.path.startIndex ... self.scope.path.endIndex).reversed()
        {
            let prefix:[String] = ["\(self.scope.namespace)"] + self.scope.path[..<index]
            if  let overloads:Overloads = self.table.query(link.scope.map
                    {
                            prefix + $0.components + link.path.components
                    } ??    prefix                 + link.path.components,
                    filter: link.filter,
                    hash: link.hash)
            {
                return overloads
            }
        }
        for namespace:ModuleIdentifier in self.scope.imports where
            namespace != self.scope.namespace
        {
            if  let overloads:Overloads = self.table.query(link.scope.map
                    {
                            ["\(namespace)"] + $0.components + link.path.components
                    } ??    ["\(namespace)"]                 + link.path.components,
                    filter: link.filter,
                    hash: link.hash)
            {
                return overloads
            }
        }

        return self.table.query(link.scope.map
            {
                [String].init($0.components) + link.path.components
            } ??                 [String].init(link.path.components),
            filter: link.filter,
            hash: link.hash)
    }
}
