import BSONDecoding
import BSONEncoding
import ModuleGraphs
import Symbols

@frozen public
struct Documentation:Equatable, Sendable
{
    public
    var graph:SymbolGraph
    public
    var files:SymbolGraph.Table<FileSymbol>

    @inlinable internal
    init(graph:SymbolGraph, files:SymbolGraph.Table<FileSymbol>)
    {
        self.graph = graph
        self.files = files
    }
}
extension Documentation
{
    public
    init(modules:[ModuleDetails])
    {
        self.init(
            graph: .init(namespaces: modules.map(\.id),
                cultures: modules.map(SymbolGraph.Culture.init(module:))),
            files: [])
    }
}
extension Documentation
{
    public
    enum CodingKeys:String
    {
        case files

        case graph_articles
        case graph_namespaces
        case graph_cultures
        case graph_symbols
        case graph_nodes
    }
}
extension Documentation:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.files] = self.files

        bson[.graph_namespaces] = self.graph.namespaces
        bson[.graph_cultures] = self.graph.cultures
        bson[.graph_articles] = self.graph.articles
        bson[.graph_symbols] = self.graph.symbols
        bson[.graph_nodes] = self.graph.nodes.elements
    }
}
extension Documentation:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            graph: .init(
                namespaces: try bson[.graph_namespaces].decode(),
                cultures: try bson[.graph_cultures].decode(),
                articles: try bson[.graph_articles].decode(),
                symbols: try bson[.graph_symbols].decode(),
                nodes: try bson[.graph_nodes].decode()),
            files: try bson[.files].decode())
    }
}
