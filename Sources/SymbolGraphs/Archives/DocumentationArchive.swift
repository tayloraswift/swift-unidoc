import BSONDecoding
import BSONEncoding

@frozen public
struct DocumentationArchive:Equatable, Sendable
{
    public
    let metadata:DocumentationMetadata

    public
    var modules:[Module]

    public
    var files:Files
    public
    var graph:SymbolGraph

    public
    init(metadata:DocumentationMetadata)
    {
        self.metadata = metadata
        self.modules = []
        self.files = .init()
        self.graph = .init()
    }
}
extension DocumentationArchive
{
    public
    enum CodingKeys:String
    {
        case metadata
        case modules
        case files_symbols
        case graph_symbols
        case graph_nodes
    }
}
extension DocumentationArchive:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.metadata] = self.metadata
        bson[.modules] = self.modules
        bson[.files_symbols] = self.files.symbols
        bson[.graph_symbols] = self.graph.symbols
        bson[.graph_nodes] = self.graph.nodes
    }
}
extension DocumentationArchive:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(metadata: try bson[.metadata].decode())

        self.modules = try bson[.modules].decode()
        self.files = .init(symbols: try bson[.files_symbols].decode())
        self.graph = .init(symbols: try bson[.graph_symbols].decode(),
            nodes: try bson[.graph_nodes].decode())
    }

    public
    init(bson:ArraySlice<UInt8>) throws
    {
        try self.init(bson: BSON.DocumentView<ArraySlice<UInt8>>.init(slice: bson))
    }
}
