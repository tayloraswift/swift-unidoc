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
        var apiLimitLeft:Int
        public
        var apiKey:Int64?

        public
        var github:GitHub.User.Profile?

        @inlinable public
        init(id:Account,
            level:Level,
            apiLimitLeft:Int = 0,
            apiKey:Int64? = nil,
            github:GitHub.User.Profile? = nil)
        {
            self.id = id
            self.level = level
            self.apiLimitLeft = apiLimitLeft
            self.apiKey = apiKey
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

    @inlinable public consuming
    func `as`(_ level:Level) -> Self
    {
        self.level = level
        return self
    }
}
extension Unidoc.User:Mongo.MasterCodingModel
{
    public
    enum CodingKey:String, Sendable
    {
        case id = "_id"
        case level = "P"

        case apiLimitLeft = "L"
        case apiKey = "A"
        /// The session cookie associated with this account, if logged in. This is generated
        /// randomly in ``AccountDatabase.Users.update(account:with:)``.
        case cookie = "B"

        case github = "github"
    }
}
extension Unidoc.User:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.level] = self.level

        bson[.apiLimitLeft] = self.apiLimitLeft
        bson[.apiKey] = self.apiKey

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
            apiLimitLeft: try bson[.apiLimitLeft]?.decode() ?? 0,
            apiKey: try bson[.apiKey]?.decode(),
            github: try bson[.github]?.decode())
    }
}
