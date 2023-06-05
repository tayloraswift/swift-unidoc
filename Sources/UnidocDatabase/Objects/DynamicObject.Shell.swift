import BSONDecoding
import BSONEncoding

extension DynamicObject
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
extension DynamicObject.Shell
{
    typealias CodingKeys = DynamicObject.CodingKeys
}
extension DynamicObject.Shell:BSONDocumentEncodable
{
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.version] = self.version
    }
}
extension DynamicObject.Shell:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(version: try bson[.version].decode())
    }
}
