import BSONDecoding
import BSONEncoding

@frozen public
struct Documentation:Equatable, Sendable
{
    public
    let metadata:Metadata
    public
    let graph:SymbolGraph

    @inlinable public
    init(metadata:Metadata, graph:SymbolGraph)
    {
        self.metadata = metadata
        self.graph = graph
    }
}
extension Documentation
{
    public
    enum CodingKeys:String
    {
        case metadata
        case graph
    }
}
extension Documentation:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.metadata] = self.metadata
        bson[.graph] = self.graph
    }
}
extension Documentation:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(metadata: try bson[.metadata].decode(), graph: try bson[.graph].decode())
    }

    public
    init(buffer:UnsafeRawBufferPointer) throws
    {
        try self.init(bson: BSON.DocumentView<UnsafeRawBufferPointer>.init(slice: buffer))
    }
    public
    init(buffer:ArraySlice<UInt8>) throws
    {
        try self.init(bson: BSON.DocumentView<ArraySlice<UInt8>>.init(slice: buffer))
    }
    public
    init(buffer:[UInt8]) throws
    {
        try self.init(buffer: buffer[...])
    }
}
