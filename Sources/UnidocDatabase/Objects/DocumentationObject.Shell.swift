import BSONDecoding
import BSONEncoding

extension DocumentationObject
{
    struct Shell:Equatable, Sendable
    {
        let version:Int32

        init(version:Int32)
        {
            self.version = version
        }
    }
}
extension DocumentationObject.Shell
{
    typealias CodingKeys = DocumentationObject.CodingKeys
}
extension DocumentationObject.Shell:BSONDocumentEncodable
{
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.version] = self.version
    }
}
extension DocumentationObject.Shell:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(version: try bson[.version].decode())
    }
}
