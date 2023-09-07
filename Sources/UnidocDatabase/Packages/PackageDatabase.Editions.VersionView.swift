import BSONDecoding
import Unidoc

extension PackageDatabase.Editions
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
extension PackageDatabase.Editions.VersionView:BSONDocumentDecodable
{
    typealias CodingKey = PackageEdition.CodingKey

    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(version: try bson[.version].decode())
    }
}
