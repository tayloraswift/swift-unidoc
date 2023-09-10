import BSONDecoding
import Unidoc

extension PackageDatabase.Editions
{
    @available(*, unavailable, message: "do we need this?")
    struct VersionView:Equatable, Sendable
    {
        let version:Int32

        init(version:Int32)
        {
            self.version = version
        }
    }
}
@available(*, unavailable)
extension PackageDatabase.Editions.VersionView:BSONDocumentDecodable
{
    typealias CodingKey = PackageEdition.CodingKey

    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(version: try bson[.version].decode())
    }
}
