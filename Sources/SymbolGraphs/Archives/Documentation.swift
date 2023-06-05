import BSONDecoding
import BSONEncoding
import Symbols

@frozen public
struct Documentation:Equatable, Sendable
{
    public
    var modules:[Module]
    public
    var files:Files
    public
    var graph:SymbolGraph

    public
    init(modules:[Module])
    {
        self.modules = modules
        self.files = .init()
        self.graph = .init()
    }
}
extension Documentation
{
    public
    enum CodingKeys:String
    {
        case modules
        case files_symbols
        case graph_symbols
        case graph_nodes
    }
}
extension Documentation:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.modules] = self.modules
        bson[.files_symbols] = self.files.symbols
        bson[.graph_symbols] = self.graph.symbols
        bson[.graph_nodes] = self.graph.nodes
    }
}
extension Documentation:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(modules: try bson[.modules].decode())

        self.files = .init(symbols: try bson[.files_symbols].decode())
        self.graph = .init(symbols: try bson[.graph_symbols].decode(),
            nodes: try bson[.graph_nodes].decode())
    }
}
