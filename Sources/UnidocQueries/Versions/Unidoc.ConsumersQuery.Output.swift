import BSON
import MongoQL
import UnidocRecords
import UnidocDB

extension Unidoc.ConsumersQuery
{
    @frozen public
    struct Output
    {
        public
        let dependency:Unidoc.PackageMetadata
        public
        let dependents:[Unidoc.PackageDependent]
        public
        let user:Unidoc.User?

        @inlinable public
        init(dependency:Unidoc.PackageMetadata,
            dependents:[Unidoc.PackageDependent],
            user:Unidoc.User?)
        {
            self.dependency = dependency
            self.dependents = dependents
            self.user = user
        }
    }
}
extension Unidoc.ConsumersQuery.Output:Mongo.MasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case dependency
        case dependents
        case user
    }
}
extension Unidoc.ConsumersQuery.Output:BSONDocumentDecodable
{
    public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            dependency: try bson[.dependency].decode(),
            dependents: try bson[.dependents].decode(),
            user: try bson[.user]?.decode())
    }
}
