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
    let zone:Unidoc.Zone
    public
    let metadata:SymbolGraphMetadata
    public
    let graph:SymbolGraph

    @inlinable public
    init(_ zone:Unidoc.Zone,
        metadata:SymbolGraphMetadata,
        graph:SymbolGraph)
    {
        self.metadata = metadata
        self.graph = graph
        self.zone = zone
    }
}
extension Snapshot:Identifiable
{
    @inlinable public
    var id:String { self.metadata.id }
}
extension Snapshot
{
    @inlinable public
    var cell:Unidoc.Cell
    {
        .init(package: self.package)
    }

    @inlinable public
    var package:Int32 { self.zone.package }

    @inlinable public
    var version:Int32 { self.zone.version }

    @inlinable public
    var stable:Bool
    {
        self.metadata.version?.stable != nil
    }
}
extension Snapshot
{
    @frozen public
    enum CodingKey:String
    {
        case id = "_id"
        case zone = "z"

        case metadata = "M"
        case graph = "D"

        //  Computed field, outlined for MongoDB’s convenience.
        //  case stable = "S"
    }
}
extension Snapshot:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.zone] = self.zone
        bson[.metadata] = self.metadata
        bson[.graph] = self.graph

        //bson[.stable] = self.stable
    }
}
extension Snapshot:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(try bson[.zone].decode(),
            metadata: try bson[.metadata].decode(),
            graph: try bson[.graph].decode())
    }
}
