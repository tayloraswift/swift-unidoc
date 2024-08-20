import Symbols
import UCF
import Unidoc

extension UCF.Overload
{
    @frozen public
    struct Resolver
    {
        public
        let table:Table
        public
        let scope:UCF.ResolutionScope

        @inlinable public
        init(table:Table, scope:UCF.ResolutionScope)
        {
            self.table = table
            self.scope = scope
        }
    }
}
extension UCF.Overload.Resolver
{
    @_specialize(where Scalar == Int32)
    @_specialize(where Scalar == Unidoc.Scalar)
    public
    func resolve(_ selector:UCF.Selector) -> UCF.Overload<Scalar>.Group
    {
        switch selector.base
        {
        case .relative:
            for index:Int in
                (self.scope.path.startIndex ... self.scope.path.endIndex).reversed()
            {
                let overloads:UCF.Overload<Scalar>.Group = self.table.query(
                    qualified: ["\(self.scope.namespace)"]
                        + self.scope.path[..<index]
                        + selector.path.components,
                    suffix: selector.suffix)

                guard overloads.isEmpty
                else
                {
                    return overloads
                }
            }
            for namespace:Symbol.Module in self.scope.imports where
                namespace != self.scope.namespace
            {
                let overloads:UCF.Overload<Scalar>.Group = self.table.query(
                    qualified: ["\(namespace)"] + selector.path.components,
                    suffix: selector.suffix)

                guard overloads.isEmpty
                else
                {
                    return overloads
                }
            }

            fallthrough

        case .qualified:
            return self.table.query(qualified: selector.path.components,
                suffix: selector.suffix)
        }
    }
}
