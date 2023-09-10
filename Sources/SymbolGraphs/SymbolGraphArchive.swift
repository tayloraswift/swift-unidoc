import BSONDecoding
import BSONEncoding

@available(*, deprecated, renamed: "SymbolGraphArchive")
public typealias Documentation = SymbolGraphArchive

/// A symbol graph archive is just a ``SymbolGraph`` with ``SymbolGraphMetadata``.
@frozen public
struct SymbolGraphArchive:Equatable, Sendable
{
    public
    var metadata:SymbolGraphMetadata
    public
    let graph:SymbolGraph

    @inlinable public
    init(metadata:SymbolGraphMetadata, graph:SymbolGraph)
    {
        self.metadata = metadata
        self.graph = graph
    }
}
extension SymbolGraphArchive
{
    public
    enum CodingKey:String
    {
        case metadata
        case graph
    }
}
extension SymbolGraphArchive:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.metadata] = self.metadata
        bson[.graph] = self.graph
    }
}
extension SymbolGraphArchive:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
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
