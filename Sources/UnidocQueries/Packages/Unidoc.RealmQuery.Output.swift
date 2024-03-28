import BSON
import MongoQL
import UnidocDB

extension Unidoc.RealmQuery
{
    @frozen public
    struct Output:Sendable
    {
        public
        let metadata:Unidoc.RealmMetadata
        public
        let packages:[Unidoc.PackageOutput]
        public
        let user:Unidoc.User?

        @inlinable public
        init(metadata:Unidoc.RealmMetadata,
            packages:[Unidoc.PackageOutput],
            user:Unidoc.User?)
        {
            self.metadata = metadata
            self.packages = packages
            self.user = user
        }
    }
}
extension Unidoc.RealmQuery.Output:Mongo.MasterCodingModel
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
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            metadata: try bson[.metadata].decode(),
            packages: try bson[.packages].decode(),
            user: try bson[.user]?.decode())
    }
}
