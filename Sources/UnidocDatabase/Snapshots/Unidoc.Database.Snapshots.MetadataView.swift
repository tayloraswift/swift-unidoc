import BSONDecoding
import Unidoc
import UnidocLinker

extension Unidoc.Database.Snapshots
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
extension Unidoc.Database.Snapshots.MetadataView
{
    var zone:Unidoc.Zone { .init(package: self.package, version: self.version) }
}
extension Unidoc.Database.Snapshots.MetadataView:BSONDocumentDecodable
{
    typealias CodingKey = Snapshot.CodingKey

    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            package: try bson[.package].decode(),
            version: try bson[.version].decode())
    }
}
