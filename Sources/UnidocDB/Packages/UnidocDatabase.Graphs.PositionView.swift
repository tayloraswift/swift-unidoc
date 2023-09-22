import BSONDecoding
import Unidoc
import UnidocLinker

extension UnidocDatabase.Graphs
{
    @available(*, unavailable, message: "do we need this?")
    struct PositionView:Equatable, Sendable
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
@available(*, unavailable)
extension UnidocDatabase.Graphs.PositionView
{
    var edition:Unidoc.Zone { .init(package: self.package, version: self.version) }
}
@available(*, unavailable)
extension UnidocDatabase.Graphs.PositionView:BSONDocumentDecodable
{
    typealias CodingKey = Snapshot.CodingKey

    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            package: try bson[.package].decode(),
            version: try bson[.version].decode())
    }
}
