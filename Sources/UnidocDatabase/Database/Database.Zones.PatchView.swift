import BSONDecoding
import SemanticVersions
import Unidoc
import UnidocRecords

extension Database.Zones
{
    struct PatchView:Equatable, Sendable
    {
        let id:Unidoc.Zone
        let patch:PatchVersion

        private
        init(id:Unidoc.Zone, patch:PatchVersion)
        {
            self.id = id
            self.patch = patch
        }
    }
}
extension Database.Zones.PatchView:BSONDocumentDecodable
{
    typealias CodingKey = Record.Zone.CodingKey

    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(), patch: try bson[.patch].decode())
    }
}
