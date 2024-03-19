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
        var github:GitHub.User.Profile?

        @inlinable public
        init(id:Account,
            level:Level,
            github:GitHub.User.Profile? = nil)
        {
            self.id = id
            self.level = level
            self.github = github
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
extension Unidoc.User:MongoMasterCodingModel
{
    public
    enum CodingKey:String, Sendable
    {
        case id = "_id"
        case level

        case github = "github"

        /// The session cookie associated with this account, if logged in. This is generated
        /// randomly in ``AccountDatabase.Users.update(account:with:)``.
        case cookie
        case apiKey
    }
}
extension Unidoc.User:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.level] = self.level
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
            github: try bson[.github]?.decode())
    }
}
