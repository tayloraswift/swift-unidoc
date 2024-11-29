import SymbolGraphs
import Unidoc

extension Unidoc
{
    protocol SortPriority:Comparable
    {
        /// Get the sort-priority of a declaration.
        static
        func of(decl:SymbolGraph.Decl, at index:Int32) -> Self?
    }
}
extension Unidoc.SortPriority
{
    static
    func of(decl:Unidoc.Scalar, in linker:borrowing Unidoc.LinkerContext) -> Self?
    {
        guard
        let graph:Unidoc.LinkableGraph = linker[decl.package]
        else
        {
            return nil
        }

        return .of(decl: decl, in: graph)
    }

    static
    func of(decl:Unidoc.Scalar, in graph:Unidoc.LinkableGraph) -> Self?
    {
        guard
        let local:Int32 = decl - graph.id,
        let decl:SymbolGraph.Decl = graph.decls[local]?.decl
        else
        {
            return nil
        }

        return .of(decl: decl, at: local)
    }
}
