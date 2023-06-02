import BSONDecoding
import BSONEncoding

@frozen public
struct DocumentationArchive:Equatable, Sendable
{
    public
    let metadata:DocumentationMetadata
    public
    let docs:Documentation

    @inlinable public
    init(metadata:DocumentationMetadata, docs:Documentation)
    {
        self.metadata = metadata
        self.docs = docs
    }
}
extension DocumentationArchive
{
    public
    enum CodingKeys:String
    {
        case metadata
        case docs
    }
}
extension DocumentationArchive:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.metadata] = self.metadata
        bson[.docs] = self.docs
    }
}
extension DocumentationArchive:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(metadata: try bson[.metadata].decode(), docs: try bson[.docs].decode())
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
