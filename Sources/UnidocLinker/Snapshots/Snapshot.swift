import BSONDecoding
import BSONEncoding
import SemanticVersions
import SymbolGraphs
import Unidoc

@frozen public
struct Snapshot:Equatable, Sendable
{
    public
    let id:String

    public
    let package:Int32
    public
    let version:Int32

    public
    let metadata:SymbolGraphMetadata
    public
    let graph:SymbolGraph

    @inlinable public
    init(id:String,
        package:Int32,
        version:Int32,
        metadata:SymbolGraphMetadata,
        graph:SymbolGraph)
    {
        self.id = id
        self.package = package
        self.version = version
        self.metadata = metadata
        self.graph = graph
    }
}
extension Snapshot
{
    @inlinable public
    var zone:Unidoc.Zone
    {
        .init(package: self.package, version: self.version)
    }

    @inlinable public
    var stable:Bool
    {
        self.metadata.version?.stable != nil
    }
}
extension Snapshot
{
    @frozen public
    enum CodingKeys:String
    {
        case id = "_id"
        case package = "P"
        case version = "V"
        case metadata = "M"
        case graph = "D"

        //  Computed field, outlined for MongoDB’s convenience.
        case stable = "S"
    }

    @inlinable public static
    subscript(key:CodingKeys) -> BSON.Key { .init(key) }
}
extension Snapshot:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.id] = self.id

        bson[.package] = self.package
        bson[.version] = self.version
        bson[.metadata] = self.metadata
        bson[.graph] = self.graph

        bson[.stable] = self.stable
    }
}
extension Snapshot:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(),
            package: try bson[.package].decode(),
            version: try bson[.version].decode(),
            metadata: try bson[.metadata].decode(),
            graph: try bson[.graph].decode())
    }
}
