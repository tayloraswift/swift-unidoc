extension SymbolGraph
{
    @frozen public
    struct Layer<Node> where Node:SymbolGraphNode
    {
        public
        var symbols:Table<Node.Plane, Node.ID>
        public
        var nodes:Table<Node.Plane, Node>

        @inlinable internal
        init(
            symbols:Table<Node.Plane, Node.ID> = [],
            nodes:Table<Node.Plane, Node> = [])
        {
            self.symbols = symbols
            self.nodes = nodes
        }
    }
}
extension SymbolGraph.Layer:Equatable where Node:Equatable
{
}
extension SymbolGraph.Layer:Sendable where Node:Sendable, Node.ID:Sendable
{
}
extension SymbolGraph.Layer
{
    /// Appends a new node to the symbol graph layer, and its associated symbol
    /// to the symbol table. This function doesn’t check for duplicates.
    @inlinable public mutating
    func append(_ node:Node, id:Node.ID) -> Int32
    {
        let symbol:Int32 = self.symbols.append(id)
        let node:Int32 = self.nodes.append(node)
        precondition(symbol == node)
        return node
    }
}
extension SymbolGraph.Layer
{
    @inlinable public
    subscript(scalar:Int32) -> Node?
    {
        self.nodes.indices.contains(scalar) ? self.nodes[scalar] : nil
    }

    @inlinable public
    func contains(citizen scalar:Int32) -> Bool
    {
        self.nodes.indices.contains(scalar) &&
        self.nodes[scalar].isCitizen
    }

    @inlinable public
    var citizens:Citizens
    {
        .init(self)
    }
}
extension SymbolGraph.Layer
{
    @inlinable public
    func link<T>(
        static transform:(Int32) throws -> T,
        dynamic link:(Node.ID) throws -> T) rethrows -> SymbolGraph.Table<Node.Plane, T>
    {
        var elements:[T] = [] ; elements.reserveCapacity(self.symbols.count)

        for index:Int32 in self.symbols.indices
        {
            elements.append(self.contains(citizen: index) ? try transform(index) :
                try link(self.symbols[index]))
        }

        return .init(storage: .init(elements: elements))
    }
}
