import BSON
import MarkdownABI
import Symbols

@frozen public
struct SymbolGraph:Equatable, Sendable
{
    /// Interned module namespace strings. This is actually not redundant with the
    /// ``cultures`` array, because ``Culture`` values derive module names from
    /// unmangled package manifest names.
    public
    var namespaces:[Symbol.Module]
    public
    var cultures:[Culture]

    public
    var articles:Layer<ArticleNode>
    public
    var decls:Layer<DeclNode>

    public
    var files:Table<FilePlane, Symbol.File>

    @inlinable internal
    init(namespaces:[Symbol.Module],
        cultures:[Culture],
        articles:Layer<ArticleNode> = .init(),
        decls:Layer<DeclNode> = .init(),
        files:Table<FilePlane, Symbol.File> = [])
    {
        self.namespaces = namespaces
        self.cultures = cultures

        self.articles = articles
        self.files = files
        self.decls = decls
    }
}
extension SymbolGraph
{
    public
    init(modules:[Module])
    {
        self.init(namespaces: modules.map(\.id),
            cultures: modules.map(SymbolGraph.Culture.init(module:)))
    }
}
extension SymbolGraph
{
    /// Appends a new namespace to the symbol graph. This function doesn’t check
    /// for duplicates, and it doesn’t check if the module name is already associated
    /// with a culture.
    @inlinable public mutating
    func append(namespace:Symbol.Module) -> Int
    {
        defer { self.namespaces.append(namespace) }
        return self.namespaces.endIndex
    }
}

extension SymbolGraph
{
    @inlinable public
    func link<T>(
        static transform:(Int32) throws -> T,
        dynamic link:(Symbol.Module) throws -> T) rethrows -> [T]
    {
        var elements:[T] = [] ; elements.reserveCapacity(self.namespaces.count)

        for index:Int in self.cultures.indices
        {
            elements.append(try transform(index * .module))
        }
        for colony:Symbol.Module in self.namespaces[self.cultures.endIndex...]
        {
            elements.append(try link(colony))
        }

        return elements
    }
}
extension SymbolGraph
{
    public
    enum CodingKey:String, Sendable
    {
        case namespaces
        case cultures

        case articles_symbols
        case articles_nodes

        case decls_symbols
        case decls_nodes

        case files
    }
}
extension SymbolGraph:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.namespaces] = self.namespaces
        bson[.cultures] = self.cultures

        bson[.articles_symbols] = self.articles.symbols
        bson[.articles_nodes] = self.articles.nodes

        bson[.decls_symbols] = self.decls.symbols
        bson[.decls_nodes] = self.decls.nodes

        bson[.files] = self.files
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
            articles: .init(
                symbols:try bson[.articles_symbols].decode(),
                nodes:try bson[.articles_nodes].decode()),
            decls: .init(
                symbols:try bson[.decls_symbols].decode(),
                nodes:try bson[.decls_nodes].decode()),
            files: try bson[.files].decode())
    }
}
