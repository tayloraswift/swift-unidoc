import SymbolGraphs
import Symbols

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
extension Snapshot.View<FileSymbol>
{
    subscript(_ scalar:Scalar96) -> FileSymbol?
    {
        self.translator[scalar: scalar].map { self.graph.files[$0] }
    }
}
extension Snapshot.View<ScalarSymbol>
{
    subscript(_ scalar:Scalar96) -> ScalarSymbol?
    {
        self.translator[scalar: scalar].map { self.graph.symbols[$0] }
    }
}
extension Snapshot.View<SymbolGraph.Node>
{
    subscript(_ scalar:Scalar96) -> SymbolGraph.Node?
    {
        self.translator[scalar: scalar].map { self.graph.nodes[$0] }
    }
}
