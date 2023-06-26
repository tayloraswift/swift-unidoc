import SymbolGraphs
import Symbols
import Unidoc

extension Snapshot
{
    struct View<T>
    {
        private
        let translator:Translator
        private
        let graph:SymbolGraph

        private
        init(translator:Translator, graph:SymbolGraph)
        {
            self.translator = translator
            self.graph = graph
        }
    }
}
extension Snapshot.View
{
    init(_ snapshot:Snapshot)
    {
        self.init(translator: snapshot.translator, graph: snapshot.graph)
    }
}
extension Snapshot.View<Symbol.File>
{
    subscript(_ scalar:Unidoc.Scalar) -> Symbol.File?
    {
        self.translator[scalar: scalar].map { self.graph.files[$0] }
    }
}
extension Snapshot.View<Symbol.Decl>
{
    subscript(_ scalar:Unidoc.Scalar) -> Symbol.Decl?
    {
        self.translator[scalar: scalar].map { self.graph.decls[$0] }
    }
}
extension Snapshot.View<SymbolGraph.Node>
{
    subscript(_ scalar:Unidoc.Scalar) -> SymbolGraph.Node?
    {
        self.translator[scalar: scalar].map { self.graph.nodes[$0] }
    }
}
