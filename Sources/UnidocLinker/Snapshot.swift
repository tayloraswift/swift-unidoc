import BSONDecoding
import BSONEncoding
import SemanticVersions
import SymbolGraphs
import Unidoc
import UnidocRecords

@frozen public
struct Snapshot:Equatable, Sendable
{
    public
    let package:Int32
    public
    let version:Int32

    public
    let metadata:SymbolGraphMetadata
    public
    let graph:SymbolGraph

    @inlinable public
    init(
        package:Int32,
        version:Int32,
        metadata:SymbolGraphMetadata,
        graph:SymbolGraph)
    {
        self.package = package
        self.version = version
        self.metadata = metadata
        self.graph = graph
    }
}
extension Snapshot
{
    @inlinable public
    init(
        package:Int32,
        version:Int32,
        archive:SymbolGraphArchive)
    {
        self.init(
            package: package,
            version: version,
            metadata: archive.metadata,
            graph: archive.graph)
    }
}
extension Snapshot:Identifiable
{
    @inlinable public
    var id:ID { self.metadata.pin }
}
extension Snapshot
{
    @inlinable public
    var edition:Unidoc.Zone
    {
        .init(package: self.package, version: self.version)
    }
}
extension Snapshot
{
    @frozen public
    enum CodingKey:String
    {
        case id = "_id"

        case package = "P"
        case version = "V"
        case metadata = "M"
        case graph = "D"
    }
}
extension Snapshot:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id

        bson[.package] = self.package
        bson[.version] = self.version
        bson[.metadata] = self.metadata
        bson[.graph] = self.graph
    }
}
extension Snapshot:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            package: try bson[.package].decode(),
            version: try bson[.version].decode(),
            metadata: try bson[.metadata].decode(),
            graph: try bson[.graph].decode())
    }
}
