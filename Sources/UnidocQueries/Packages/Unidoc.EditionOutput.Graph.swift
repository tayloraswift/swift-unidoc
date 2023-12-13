import BSON
import MongoQL
import SemanticVersions
import SymbolGraphs
import UnidocRecords

extension Unidoc.EditionOutput
{
    @frozen public
    struct Graph:Equatable, Sendable
    {
        public
        let bytes:Int
        public
        let abi:PatchVersion

        @inlinable public
        init(bytes:Int, abi:PatchVersion)
        {
            self.bytes = bytes
            self.abi = abi
        }
    }
}
extension Unidoc.EditionOutput.Graph:MongoMasterCodingModel
{
    public
    enum CodingKey:String, Sendable
    {
        case bytes
        case abi
    }
}
extension Unidoc.EditionOutput.Graph:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(bytes: try bson[.bytes].decode(), abi: try bson[.abi].decode())
    }
}
