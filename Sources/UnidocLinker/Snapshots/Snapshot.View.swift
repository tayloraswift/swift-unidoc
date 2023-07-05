import SymbolGraphs
import Symbols
import Unidoc

extension Snapshot
{
    struct View<T>
    {
        private
        let graph:SymbolGraph
        private
        let zone:Unidoc.Zone

        private
        init(graph:SymbolGraph, zone:Unidoc.Zone)
        {
            self.graph = graph
            self.zone = zone
        }
    }
}
extension Snapshot.View
{
    init(_ snapshot:__shared Snapshot)
    {
        self.init(graph: snapshot.graph, zone: snapshot.zone)
    }
}
extension Snapshot.View<Symbol.File>
{
    subscript(_ scalar:Unidoc.Scalar) -> Symbol.File?
    {
        (scalar - self.zone).map { self.graph.files[$0] }
    }
}
extension Snapshot.View<Symbol.Decl>
{
    subscript(_ scalar:Unidoc.Scalar) -> Symbol.Decl?
    {
        (scalar - self.zone).map { self.graph.decls[$0] }
    }
}
extension Snapshot.View<SymbolGraph.Node>
{
    subscript(_ scalar:Unidoc.Scalar) -> SymbolGraph.Node?
    {
        (scalar - self.zone).map { self.graph.nodes[$0] }
    }
}
