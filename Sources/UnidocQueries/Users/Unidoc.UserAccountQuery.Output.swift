import BSON
import MongoQL
import UnidocDB
import UnidocRecords

extension Unidoc.UserAccountQuery
{
    @frozen public
    struct Output
    {
        public
        let user:Unidoc.User
        public
        let organizations:[Unidoc.User]

        @inlinable public
        init(user:Unidoc.User,
            organizations:[Unidoc.User])
        {
            self.user = user
            self.organizations = organizations
        }
    }
}
extension Unidoc.UserAccountQuery.Output:Mongo.MasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case user
        case organizations
    }
}
extension Unidoc.UserAccountQuery.Output:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(user: try bson[.user].decode(),
            organizations: try bson[.organizations].decode())
    }
}
