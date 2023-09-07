import BSONDecoding
import Unidoc
import UnidocLinker

extension PackageDatabase.Graphs
{
    struct ZoneView
    {
        let zone:Unidoc.Zone

        init(zone:Unidoc.Zone)
        {
            self.zone = zone
        }
    }
}
extension PackageDatabase.Graphs.ZoneView:BSONDocumentDecodable
{
    typealias CodingKey = Snapshot.CodingKey

    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(zone: try bson[.zone].decode())
    }
}
