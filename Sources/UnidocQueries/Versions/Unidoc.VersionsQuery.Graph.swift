import BSON
import MongoQL
import SemanticVersions
import SymbolGraphs
import UnidocRecords

extension Unidoc.VersionsQuery
{
    @frozen public
    struct Graph:Equatable, Sendable
    {
        public
        let id:Unidoc.Edition
        public
        let uplinking:Bool
        public
        let bytes:Int
        public
        let abi:PatchVersion

        @inlinable public
        init(id:Unidoc.Edition, uplinking:Bool, bytes:Int, abi:PatchVersion)
        {
            self.id = id
            self.uplinking = uplinking
            self.bytes = bytes
            self.abi = abi
        }
    }
}
extension Unidoc.VersionsQuery.Graph:MongoMasterCodingModel
{
    public
    enum CodingKey:String, Sendable
    {
        case id = "_id"
        case uplinking
        case bytes
        case abi
    }
}
extension Unidoc.VersionsQuery.Graph:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(),
            uplinking: try bson[.uplinking].decode(),
            bytes: try bson[.bytes].decode(),
            abi: try bson[.abi].decode())
    }
}
