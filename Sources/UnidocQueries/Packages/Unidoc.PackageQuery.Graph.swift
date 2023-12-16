import BSON
import MongoQL
import SemanticVersions
import SymbolGraphs
import UnidocRecords

extension Unidoc.PackageQuery
{
    @frozen public
    struct Graph:Equatable, Sendable
    {
        public
        let uplinking:Bool
        public
        let bytes:Int
        public
        let abi:PatchVersion

        @inlinable public
        init(uplinking:Bool, bytes:Int, abi:PatchVersion)
        {
            self.uplinking = uplinking
            self.bytes = bytes
            self.abi = abi
        }
    }
}
extension Unidoc.PackageQuery.Graph:MongoMasterCodingModel
{
    public
    enum CodingKey:String, Sendable
    {
        case uplinking
        case bytes
        case abi
    }
}
extension Unidoc.PackageQuery.Graph:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            uplinking: try bson[.uplinking].decode(),
            bytes: try bson[.bytes].decode(),
            abi: try bson[.abi].decode())
    }
}
