import BSONDecoding
import BSONEncoding
import MarkdownABI
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
    var symbols:Table<ScalarSymbol>
    public
    var nodes:Table<Node>

    public
    var articles:Plane<Articles, Article<String>>
    public
    var files:Plane<Files, FileSymbol>

    @inlinable internal
    init(namespaces:[ModuleIdentifier],
        cultures:[Culture],
        symbols:Table<ScalarSymbol> = [],
        nodes:Table<Node> = [],
        articles:Plane<Articles, Article<String>> = [],
        files:Plane<Files, FileSymbol> = [])
    {
        self.namespaces = namespaces
        self.cultures = cultures

        self.symbols = symbols
        self.nodes = nodes

        self.articles = articles
        self.files = files
    }
}
extension SymbolGraph
{
    public
    init(modules:[ModuleDetails])
    {
        self.init(namespaces: modules.map(\.id),
            cultures: modules.map(SymbolGraph.Culture.init(module:)))
    }
}
extension SymbolGraph
{
    /// Appends a new node to the symbol graph, and its associated symbol to the
    /// symbol. This function doesn’t check for duplicates.
    @inlinable public mutating
    func append(_ scalar:SymbolGraph.Scalar?, id:ScalarSymbol) -> Int32
    {
        let symbol:Int32 = self.symbols.append(id)
        let node:Int32 = self.nodes.append(.init(scalar: scalar))
        assert(symbol == node)
        return node
    }

    /// Appends a new namespace to the symbol graph. This function doesn’t check
    /// for duplicates, and it doesn’t check if the module name is already associated
    /// with a culture.
    @inlinable public mutating
    func append(namespace:ModuleIdentifier) -> Int
    {
        defer { self.namespaces.append(namespace) }
        return self.namespaces.endIndex
    }
}
extension SymbolGraph
{
    @inlinable public
    subscript(address:Int32) -> SymbolGraph.Node?
    {
        self.nodes.indices.contains(address) ? self.nodes[address] : nil
    }

    @inlinable public
    var citizens:Citizens
    {
        .init(symbols: self.symbols, nodes: self.nodes)
    }
}
extension SymbolGraph
{
    @inlinable public
    func link<T>(
        static transform:(Int32) throws -> T,
        dynamic:(ScalarSymbol) throws -> T) rethrows -> Table<T>
    {
        var elements:[T] = [] ; elements.reserveCapacity(self.symbols.count)

        for index:Int32 in self.symbols.indices
        {
            elements.append(self.citizens.contains(index) ? try transform(index) :
                try dynamic(self.symbols[index]))
        }

        return .init(elements: elements)
    }
}
extension SymbolGraph
{
    public
    enum CodingKeys:String
    {
        case namespaces
        case cultures
        case symbols
        case nodes
        case articles
        case files
    }
}
extension SymbolGraph:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.namespaces] = self.namespaces
        bson[.cultures] = self.cultures
        bson[.symbols] = self.symbols
        bson[.nodes] = self.nodes.elements
        bson[.articles] = self.articles
        bson[.files] = self.files
    }
}
extension SymbolGraph:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            namespaces: try bson[.namespaces].decode(),
            cultures: try bson[.cultures].decode(),
            symbols: try bson[.symbols].decode(),
            nodes: try bson[.nodes].decode(),
            articles: try bson[.articles].decode(),
            files: try bson[.files].decode())
    }
}
