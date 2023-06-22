import BSONDecoding
import BSONEncoding

extension Snapshot
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
extension Snapshot.Shell
{
    typealias CodingKeys = Snapshot.CodingKeys
}
extension Snapshot.Shell:BSONDocumentEncodable
{
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.version] = self.version
    }
}
extension Snapshot.Shell:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(version: try bson[.version].decode())
    }
}
