import BSONDecoding
import BSONEncoding

@frozen public
struct SymbolGraph:Equatable, Sendable
{
    //  TODO: this should be non-optional
    public
    let metadata:Metadata?

    public
    var files:Files
    public
    var nodes:Nodes

    public
    init(metadata:Metadata?)
    {
        self.metadata = metadata
        self.files = .init()
        self.nodes = .init()
    }
}
extension SymbolGraph
{
    @inlinable public
    subscript(address:ScalarAddress) -> SymbolGraph.Scalar?
    {
        _read
        {
            yield  self.nodes[address].scalar
        }
        _modify
        {
            yield &self.nodes[address].scalar
        }
    }
    @inlinable public
    subscript(address:ScalarAddress, extension:Int) -> SymbolGraph.Extension
    {
        _read
        {
            yield  self.nodes[address].extensions[`extension`]
        }
        _modify
        {
            yield &self.nodes[address].extensions[`extension`]
        }
    }
}
extension SymbolGraph
{
    public
    enum CodingKeys:String
    {
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
        self.init(metadata: nil)
        self.files = .init(symbols: try bson[.files_symbols].decode())
        self.nodes = .init(symbols: try bson[.nodes_symbols].decode(),
            values: try bson[.nodes_values].decode())
    }
}
