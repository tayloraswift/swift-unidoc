import BSONDecoding
import BSONEncoding
import SymbolGraphs

struct DynamicObject:Equatable, Sendable
{
    let id:String

    let package:Int32
    let version:Int32

    let metadata:Documentation.Metadata
    let graph:SymbolGraph

    init(id:String,
        package:Int32,
        version:Int32,
        metadata:Documentation.Metadata,
        graph:SymbolGraph)
    {
        self.id = id
        self.package = package
        self.version = version
        self.metadata = metadata
        self.graph = graph
    }
}
extension DynamicObject
{
    var stable:Bool
    {
        switch self.metadata.ref
        {
        case .version?:         return true
        case .unstable?, nil:   return false
        }
    }
}
extension DynamicObject
{
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

    static
    subscript(key:CodingKeys) -> String
    {
        key.rawValue
    }
}
extension DynamicObject:BSONDocumentEncodable
{
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
extension DynamicObject:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(),
            package: try bson[.package].decode(),
            version: try bson[.version].decode(),
            metadata: try bson[.metadata].decode(),
            graph: try bson[.graph].decode())
    }
}
