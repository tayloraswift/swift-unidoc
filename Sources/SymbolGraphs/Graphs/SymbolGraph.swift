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
    var articles:Plane<Articles, Article<String>>
    public
    var files:Plane<Files, Symbol.File>
    public
    var decls:Table<Symbol.Decl>
    public
    var nodes:Table<Node>

    @inlinable internal
    init(namespaces:[ModuleIdentifier],
        cultures:[Culture],
        articles:Plane<Articles, Article<String>> = [],
        files:Plane<Files, Symbol.File> = [],
        decls:Table<Symbol.Decl> = [],
        nodes:Table<Node> = [])
    {
        self.namespaces = namespaces
        self.cultures = cultures


        self.articles = articles
        self.files = files
        self.decls = decls
        self.nodes = nodes
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
    func append(_ citizen:SymbolGraph.Decl?, id:Symbol.Decl) -> Int32
    {
        let symbol:Int32 = self.decls.append(id)
        let node:Int32 = self.nodes.append(.init(decl: citizen))
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
        .init(symbols: self.decls, nodes: self.nodes)
    }
}
extension SymbolGraph
{
    @inlinable public
    func link<T>(
        static transform:(Int32) throws -> T,
        dynamic:(Symbol.Decl) throws -> T) rethrows -> Table<T>
    {
        var elements:[T] = [] ; elements.reserveCapacity(self.decls.count)

        for index:Int32 in self.decls.indices
        {
            elements.append(self.citizens.contains(index) ? try transform(index) :
                try dynamic(self.decls[index]))
        }

        return .init(elements: elements)
    }
}
extension SymbolGraph
{
    public
    enum CodingKey:String
    {
        case namespaces
        case cultures
        case articles
        case files
        case decls
        case nodes
    }
}
extension SymbolGraph:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.namespaces] = self.namespaces
        bson[.cultures] = self.cultures
        bson[.articles] = self.articles
        bson[.files] = self.files
        bson[.decls] = self.decls
        bson[.nodes] = self.nodes
    }
}
extension SymbolGraph:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            namespaces: try bson[.namespaces].decode(),
            cultures: try bson[.cultures].decode(),
            articles: try bson[.articles].decode(),
            files: try bson[.files].decode(),
            decls: try bson[.decls].decode(),
            nodes: try bson[.nodes].decode())
    }
}
