import BSON
import MongoQL
import SemanticVersions
import SymbolGraphs
import UnidocAPI
import UnidocRecords

extension Unidoc.VersionsQuery
{
    @available(*, deprecated)
    public
    typealias Graph = Unidoc.VersionState.Graph
}
extension Unidoc.VersionState
{
    @frozen public
    struct Graph:Equatable, Sendable
    {
        public
        let id:Unidoc.Edition
        public
        let inlineBytes:Int?
        public
        let remoteBytes:Int

        public
        let action:Unidoc.Snapshot.PendingAction?
        public
        let abi:PatchVersion

        @inlinable public
        init(id:Unidoc.Edition,
            inlineBytes:Int?,
            remoteBytes:Int,
            action:Unidoc.Snapshot.PendingAction?,
            abi:PatchVersion)
        {
            self.id = id
            self.inlineBytes = inlineBytes
            self.remoteBytes = remoteBytes
            self.action = action
            self.abi = abi
        }
    }
}
extension Unidoc.VersionState.Graph:Mongo.MasterCodingModel
{
    public
    enum CodingKey:String, Sendable
    {
        case id = "_id"
        case inlineBytes
        case remoteBytes
        case action
        case abi
    }
}
extension Unidoc.VersionState.Graph:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(id: try bson[.id].decode(),
            inlineBytes: try bson[.inlineBytes]?.decode(),
            remoteBytes: try bson[.remoteBytes].decode(),
            action: try bson[.action]?.decode(),
            abi: try bson[.abi].decode())
    }
}
