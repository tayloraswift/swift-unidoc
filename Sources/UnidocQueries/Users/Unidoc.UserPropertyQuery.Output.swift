import BSON
import MongoQL
import UnidocDB
import UnidocRecords

extension Unidoc.UserPropertyQuery
{
    @frozen public
    struct Output
    {
        public
        let user:Unidoc.User
        public
        let packages:[Unidoc.PackageOutput]

        @inlinable public
        init(user:Unidoc.User,
            packages:[Unidoc.PackageOutput])
        {
            self.user = user
            self.packages = packages
        }
    }
}
extension Unidoc.UserPropertyQuery.Output:Mongo.MasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case user
        case packages
    }
}
extension Unidoc.UserPropertyQuery.Output:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(user: try bson[.user].decode(),
            packages: try bson[.packages].decode())
    }
}
