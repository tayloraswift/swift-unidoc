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
        let bytes:Int
        public
        let link:Unidoc.Snapshot.LinkState?
        public
        let abi:PatchVersion

        @inlinable public
        init(id:Unidoc.Edition, bytes:Int, link:Unidoc.Snapshot.LinkState?, abi:PatchVersion)
        {
            self.id = id
            self.bytes = bytes
            self.link = link
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
        case bytes
        case link
        case abi
    }
}
extension Unidoc.VersionsQuery.Graph:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(),
            bytes: try bson[.bytes].decode(),
            link: try bson[.link]?.decode(),
            abi: try bson[.abi].decode())
    }
}
