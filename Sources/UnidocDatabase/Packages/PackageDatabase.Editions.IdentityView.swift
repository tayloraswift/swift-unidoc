import BSONDecoding
import Unidoc

extension PackageDatabase.Editions
{
    struct IdentityView:Equatable, Sendable
    {
        let id:Unidoc.Zone

        init(id:Unidoc.Zone)
        {
            self.id = id
        }
    }
}
extension PackageDatabase.Editions.IdentityView:BSONDocumentDecodable
{
    typealias CodingKey = PackageEdition.CodingKey

    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode())
    }
}
