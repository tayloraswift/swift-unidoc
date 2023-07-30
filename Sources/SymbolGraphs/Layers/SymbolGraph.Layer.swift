extension SymbolGraph
{
    @frozen public
    struct Layer<Node> where Node:SymbolGraphNode
    {
        public
        var symbols:Plane<Node.Plane, Node.ID>
        public
        var nodes:Plane<Node.Plane, Node>

        @inlinable internal
        init(
            symbols:Plane<Node.Plane, Node.ID> = [],
            nodes:Plane<Node.Plane, Node> = [])
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
    subscript(citizen:Int32) -> Node?
    {
        self.nodes.indices.contains(citizen) ? self.nodes[citizen] : nil
    }

    @inlinable public
    func contains(citizen:Int32) -> Bool
    {
        self.nodes.indices.contains(citizen) &&
        self.nodes[citizen].isCitizen
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
        dynamic link:(Node.ID) throws -> T) rethrows -> SymbolGraph.Plane<Node.Plane, T>
    {
        var elements:[T] = [] ; elements.reserveCapacity(self.symbols.count)

        for index:Int32 in self.symbols.indices
        {
            elements.append(self.contains(citizen: index) ? try transform(index) :
                try link(self.symbols[index]))
        }

        return .init(table: .init(elements: elements))
    }
}
