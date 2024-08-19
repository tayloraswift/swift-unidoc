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

    /// All of the curated topics defined in this package. The purpose of these arrays is to
    /// produce generated “See also” sections in linked documentation. Such sections will never
    /// appear on types outside of the package, so all of the addresses are local.
    ///
    /// New in 0.8.24.
    public
    var curation:[[Int32]]

    public
    var articles:Layer<ArticleNode>
    public
    var decls:Layer<DeclNode>

    public
    var files:Table<FilePlane, Symbol.File>

    @inlinable internal
    init(namespaces:[Symbol.Module],
        cultures:[Culture],
        curation:[[Int32]] = [],
        articles:Layer<ArticleNode> = .init(),
        decls:Layer<DeclNode> = .init(),
        files:Table<FilePlane, Symbol.File> = [])
    {
        self.namespaces = namespaces
        self.cultures = cultures
        self.curation = curation

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
    func link<T>(_ transform:(Symbol.Module, Int32) throws -> T,
        dynamic link:(Symbol.Module) throws -> T) rethrows -> [T]
    {
        var elements:[T] = [] ; elements.reserveCapacity(self.namespaces.count)

        for (index, id):(Int, Symbol.Module) in zip(self.namespaces.indices, self.namespaces)
        {
            elements.append(self.cultures.indices.contains(index)
                ? try transform(id, index * .module)
                : try link(id))
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
        case curation

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
        bson[.curation] = self.curation.isEmpty ? nil : self.curation

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
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            namespaces: try bson[.namespaces].decode(),
            cultures: try bson[.cultures].decode(),
            curation: try bson[.curation]?.decode() ?? [],
            articles: .init(
                symbols:try bson[.articles_symbols].decode(),
                nodes:try bson[.articles_nodes].decode()),
            decls: .init(
                symbols:try bson[.decls_symbols].decode(),
                nodes:try bson[.decls_nodes].decode()),
            files: try bson[.files].decode())
    }
}
