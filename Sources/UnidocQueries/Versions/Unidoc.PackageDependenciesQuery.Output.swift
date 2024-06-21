import BSON
import MongoQL
import UnidocRecords
import UnidocDB

extension Unidoc.PackageDependenciesQuery
{
    @frozen public
    struct Output
    {
        public
        let dependency:Unidoc.PackageMetadata
        public
        let dependents:[Unidoc.PackageDependent]

        @inlinable public
        init(dependency:Unidoc.PackageMetadata, dependents:[Unidoc.PackageDependent])
        {
            self.dependency = dependency
            self.dependents = dependents
        }
    }
}
extension Unidoc.PackageDependenciesQuery.Output:Mongo.MasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case dependency
        case dependents
    }
}
extension Unidoc.PackageDependenciesQuery.Output:BSONDocumentDecodable
{
    public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            dependency: try bson[.dependency].decode(),
            dependents: try bson[.dependents].decode())
    }
}
