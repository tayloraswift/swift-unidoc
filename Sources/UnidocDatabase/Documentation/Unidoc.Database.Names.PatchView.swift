import BSONDecoding
import SemanticVersions
import Unidoc
import UnidocRecords

extension Unidoc.Database.Names
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
extension Unidoc.Database.Names.PatchView:BSONDocumentDecodable
{
    typealias CodingKey = Volume.Names.CodingKey

    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(), patch: try bson[.patch].decode())
    }
}
