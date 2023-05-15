import BSONDecoding
import BSONEncoding

@frozen public
struct SymbolGraph:Equatable, Sendable
{
    public
    let metadata:Metadata

    public
    var modules:[Module]

    public
    var files:Files
    public
    var nodes:Nodes

    public
    init(metadata:Metadata)
    {
        self.metadata = metadata
        self.modules = []
        self.files = .init()
        self.nodes = .init()
    }
}
extension SymbolGraph
{
    public
    enum CodingKeys:String
    {
        case metadata
        case modules
        case files_symbols
        case nodes_symbols
        case nodes_values
    }
}
extension SymbolGraph:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.metadata] = self.metadata
        bson[.modules] = self.modules
        bson[.files_symbols] = self.files.symbols
        bson[.nodes_symbols] = self.nodes.symbols
        bson[.nodes_values] = self.nodes.values
    }
}
extension SymbolGraph:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(metadata: try bson[.metadata].decode())

        self.modules = try bson[.modules].decode()
        self.files = .init(symbols: try bson[.files_symbols].decode())
        self.nodes = .init(symbols: try bson[.nodes_symbols].decode(),
            values: try bson[.nodes_values].decode())
    }
}
