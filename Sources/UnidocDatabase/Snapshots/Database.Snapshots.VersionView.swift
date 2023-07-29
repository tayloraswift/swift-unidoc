import BSONDecoding
import UnidocLinker

extension Database.Snapshots
{
    struct VersionView:Equatable, Sendable
    {
        let version:Int32

        init(version:Int32)
        {
            self.version = version
        }
    }
}
extension Database.Snapshots.VersionView:BSONDocumentDecodable
{
    typealias CodingKey = Snapshot.CodingKey

    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        for field in bson
        {
            print(field)
        }
        self.init(version: try bson[.version].decode())
    }
}
