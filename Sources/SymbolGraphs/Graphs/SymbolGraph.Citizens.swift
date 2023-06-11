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
        let symbols:SymbolTable<ScalarAddress, ScalarSymbol>
        @usableFromInline internal
        let nodes:[Node]

        @inlinable internal
        init(symbols:SymbolTable<ScalarAddress, ScalarSymbol>, nodes:[Node])
        {
            self.symbols = symbols
            self.nodes = nodes
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
        self.nodes.indices.contains(offset) &&
        self.nodes[offset].scalar != nil
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
