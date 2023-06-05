extension SymbolGraph
{
    /// A sequence view of the citizen symbols of this symbolgraph. Citizen symbols
    /// are symbols associated with a scalar that is declared by a module in this
    /// symbolgraph.
    @frozen public
    struct Citizens
    {
        @usableFromInline internal
        let graph:SymbolGraph

        @inlinable internal
        init(_ graph:SymbolGraph)
        {
            self.graph = graph
        }
    }
}
extension SymbolGraph.Citizens
{
    @inlinable public
    func contains(_ address:ScalarAddress) -> Bool
    {
        self.contains(address.offset)
    }
    @inlinable internal
    func contains(_ offset:Int) -> Bool
    {
        self.graph.nodes.indices.contains(offset) &&
        self.graph.nodes[offset].scalar != nil
    }
}
extension SymbolGraph.Citizens:Sequence
{
    @inlinable public
    func makeIterator() -> Iterator
    {
        .init(self)
    }
}
