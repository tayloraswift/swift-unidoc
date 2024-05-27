import BSON
import MongoQL
import SemanticVersions
import SHA1
import SymbolGraphs
import UnidocAPI
import UnidocRecords

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
        let action:Unidoc.LinkerAction?
        public
        let commit:SHA1?
        public
        let abi:PatchVersion

        @inlinable public
        init(id:Unidoc.Edition,
            inlineBytes:Int?,
            remoteBytes:Int,
            action:Unidoc.LinkerAction?,
            commit:SHA1?,
            abi:PatchVersion)
        {
            self.id = id
            self.inlineBytes = inlineBytes
            self.remoteBytes = remoteBytes
            self.action = action
            self.commit = commit
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
        case commit
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
            commit: try bson[.commit]?.decode(),
            abi: try bson[.abi].decode())
    }
}
