import ModuleGraphs
import Symbols

@frozen public
struct SymbolGraph:Equatable, Sendable
{
    /// Interned module namespace strings. This is actually not redundant with the
    /// ``cultures`` array, because ``Culture`` values derive module names from
    /// unmangled package manifest names.
    public
    var namespaces:[ModuleIdentifier]
    public
    var cultures:[Culture]

    public
    var symbols:SymbolTable<ScalarAddress, ScalarSymbol>
    public
    var nodes:Nodes

    @inlinable internal
    init(namespaces:[ModuleIdentifier],
        cultures:[Culture],
        symbols:SymbolTable<ScalarAddress, ScalarSymbol> = .init(),
        nodes:Nodes = [])
    {
        self.namespaces = namespaces
        self.cultures = cultures
        self.symbols = symbols
        self.nodes = nodes
    }
}
extension SymbolGraph
{
    /// Appends a new node to the symbol graph, and its associated symbol to the
    /// symbol. This function doesn’t check for duplicates.
    @inlinable public mutating
    func append(_ scalar:SymbolGraph.Scalar?, id:ScalarSymbol) throws -> ScalarAddress
    {
        self.nodes.append(scalar: scalar)
        return try self.symbols.append(id)
    }

    /// Appends a new namespace to the symbol graph. This function doesn’t check
    /// for duplicates, and it doesn’t check if the module name is already associated
    /// with a culture.
    @inlinable public mutating
    func append(_ namespace:ModuleIdentifier) -> Int
    {
        defer { self.namespaces.append(namespace) }
        return self.namespaces.endIndex
    }
}
extension SymbolGraph:RandomAccessCollection
{
    @inlinable public
    var startIndex:Int
    {
        self.nodes.elements.startIndex
    }
    @inlinable public
    var endIndex:Int
    {
        self.nodes.elements.endIndex
    }
    @inlinable public
    subscript(index:Int) -> (address:ScalarAddress, node:Node)
    {
        return (.init(value: .init(index)), self.nodes.elements[index])
    }
}
extension SymbolGraph
{
    @inlinable public
    subscript(address:ScalarAddress) -> SymbolGraph.Node?
    {
        self.nodes.contains(address) ? self.nodes[address] : nil
    }

    @inlinable public
    var citizens:Citizens
    {
        .init(symbols: self.symbols, nodes: self.nodes.elements)
    }
}
extension SymbolGraph
{
    @inlinable public
    func link<T>(
        static transform:(Int) throws -> T,
        dynamic:(ScalarSymbol) throws -> T) rethrows -> SymbolTable<ScalarAddress, T>
    {
        var elements:[T] = [] ; elements.reserveCapacity(self.symbols.count)

        for index:Int in self.symbols.indices
        {
            elements.append(self.citizens.contains(index) ? try transform(index) :
                try dynamic(self.symbols[index]))
        }

        return .init(elements: elements)
    }
}
