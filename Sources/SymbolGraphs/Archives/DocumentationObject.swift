import BSONDecoding
import BSONEncoding
import SemanticVersions

@frozen public
struct DocumentationObject:Equatable, Sendable
{
    public
    let metadata:DocumentationMetadata
    public
    let archive:DocumentationArchive

    @inlinable public
    init(metadata:DocumentationMetadata, archive:DocumentationArchive)
    {
        self.metadata = metadata
        self.archive = archive
    }
}
extension DocumentationObject
{
    public
    enum CodingKeys:String
    {
        case id = "_id"

        case metadata
        case archive
    }
}
extension DocumentationObject:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.id] = self.metadata.id

        bson[.metadata] = self.metadata
        bson[.archive] = self.archive
    }
}
extension DocumentationObject:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        //  ignore id.
        self.init(
            metadata: try bson[.metadata].decode(),
            archive: try bson[.archive].decode())
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
