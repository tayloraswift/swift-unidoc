import Symbols

extension SymbolGraph
{
    /// A sequence view of the citizen symbols of this symbolgraph. Citizen symbols
    /// are symbols associated with a scalar that is declared by a module in this
    /// symbolgraph.
    @frozen public
    struct Citizens
    {
        @usableFromInline internal
        let symbols:Table<Symbol.Decl>
        @usableFromInline internal
        let nodes:Table<Node>

        @inlinable internal
        init(symbols:Table<Symbol.Decl>, nodes:Table<Node>)
        {
            self.symbols = symbols
            self.nodes = nodes
        }
    }
}
extension SymbolGraph.Citizens
{
    @inlinable public
    func contains(_ address:Int32) -> Bool
    {
        self.nodes.indices.contains(address) &&
        self.nodes[address].decl != nil
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
