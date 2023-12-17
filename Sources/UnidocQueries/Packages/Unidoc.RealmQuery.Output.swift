import BSON
import MongoQL
import UnidocDB

extension Unidoc.RealmQuery
{
    @frozen public
    struct Output:Equatable, Sendable
    {
        public
        let metadata:Unidoc.RealmMetadata
        public
        let packages:[Unidoc.PackageMetadata]
        public
        let user:Unidoc.User?

        @inlinable public
        init(metadata:Unidoc.RealmMetadata,
            packages:[Unidoc.PackageMetadata],
            user:Unidoc.User?)
        {
            self.metadata = metadata
            self.packages = packages
            self.user = user
        }
    }
}
extension Unidoc.RealmQuery.Output:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case metadata
        case packages
        case user
    }
}
extension Unidoc.RealmQuery.Output:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            metadata:try bson[.metadata].decode(),
            packages:try bson[.packages].decode(),
            user:try bson[.user]?.decode())
    }
}
