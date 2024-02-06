import BSON
import GitHubAPI
import MongoQL
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct User:Identifiable, Sendable
    {
        public
        var id:Account
        public
        var level:Level
        public
        var realm:Unidoc.Realm?

        public
        var github:GitHub.User<Void>?

        @inlinable public
        init(id:Account,
            level:Level,
            realm:Unidoc.Realm? = nil,
            github:GitHub.User<Void>? = nil)
        {
            self.id = id

            self.level = level
            self.realm = realm

            self.github = nil
        }
    }
}
extension Unidoc.User
{
    @inlinable public static
    func machine(_ number:UInt32 = 0) -> Self
    {
        .init(id: .init(type: .unidoc, user: number), level: .machine)
    }
}
extension Unidoc.User
{
    @inlinable public
    func maintains(package:Unidoc.PackageMetadata) -> Bool
    {
        if  case .administratrix = self.level
        {
            true
        }
        else
        {
            //  We currently don’t have a way to determine if a user maintains a package.
            false
        }
    }
}
extension Unidoc.User:MongoMasterCodingModel
{
    public
    enum CodingKey:String, Sendable
    {
        case id = "_id"
        case level
        case realm

        case github = "github"

        /// The session cookie associated with this account, if logged in. This is generated
        /// randomly in ``AccountDatabase.Users.update(account:with:)``.
        case cookie
    }
}
extension Unidoc.User
{
    func encode(set:inout Mongo.UpdateFieldsEncoder<Mongo.UpdateDocumentEncoder.Assignment>)
    {
        set[Self[.id]] = self.id
        set[Self[.level]] = self.level
        set[Self[.realm]] = self.realm
        set[Self[.github]] { $0[.literal] = self.github }
    }
}
extension Unidoc.User:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id

        bson[.level] = self.level
        bson[.realm] = self.realm

        bson[.github] = self.github
    }
}
extension Unidoc.User:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(id: try bson[.id].decode(),
            level: try bson[.level].decode(),
            realm: try bson[.realm]?.decode(),
            github: try bson[.github]?.decode())
    }
}
