import BSONDecoding
import Unidoc
import UnidocLinker

extension Database.Snapshots
{
    struct MetadataView:Equatable, Sendable
    {
        let package:Int32
        let version:Int32

        init(package:Int32, version:Int32)
        {
            self.package = package
            self.version = version
        }
    }
}
extension Database.Snapshots.MetadataView
{
    var zone:Unidoc.Zone { .init(package: self.package, version: self.version) }
}
extension Database.Snapshots.MetadataView:BSONDocumentDecodable
{
    typealias CodingKeys = Snapshot.CodingKeys

    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            package: try bson[.package].decode(),
            version: try bson[.version].decode())
    }
}
