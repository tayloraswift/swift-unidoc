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
        /// A human-readable label for this user, if available.
        public
        var symbol:String?

        public
        var github:GitHub.User.Profile?

        /// Additional accounts that this user has access to.
        public
        var access:[Account]

        @inlinable public
        init(id:Account,
            level:Level,
            apiLimitLeft:Int = 0,
            apiKey:Int64? = nil,
            symbol:String? = nil,
            github:GitHub.User.Profile? = nil,
            access:[Account] = [])
        {
            self.id = id
            self.level = level
            self.apiLimitLeft = apiLimitLeft
            self.apiKey = apiKey
            self.symbol = symbol
            self.github = github
            self.access = access
        }
    }
}
extension Unidoc.User
{
    @inlinable public static
    func github(_ user:GitHub.User, initialLimit:Int) -> Self
    {
        /// r u taylor swift?
        let level:Unidoc.User.Level = user.id == 2556986 ? .administratrix : .human
        let id:Unidoc.Account = .init(type: .github, user: user.id)
        return .init(id: id,
            level: level,
            //  This will only be written to the database if the user is new.
            apiLimitLeft: initialLimit,
            symbol: user.profile.login,
            github: user.profile)
    }

    @inlinable public static
    func machine(_ number:UInt32 = 0) -> Self
    {
        .init(id: .init(type: .unidoc, user: number), level: .machine)
    }
}
extension Unidoc.User
{
    @inlinable public
    var rights:Unidoc.UserRights { .init(access: self.access, level: self.level) }

    @inlinable public
    var name:String? { self.github?.name ?? self.symbol }
    @inlinable public
    var bio:String? { self.github?.bio }
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
        case symbol = "Y"

        case github = "github"

        case access = "a"
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
        bson[.symbol] = self.symbol

        bson[.github] = self.github

        bson[.access] = self.access.isEmpty ? nil : self.access
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
            symbol: try bson[.symbol]?.decode(),
            github: try bson[.github]?.decode(),
            access: try bson[.access]?.decode() ?? [])
    }
}
extension Unidoc.User
{
    static
    func += (u:inout Mongo.UpdateEncoder, self:Self)
    {
        //  Set the fields individually, to avoid overwriting session cookie and/or
        //  generated API keys.
        u[.set]
        {
            $0[Self[.id]] = self.id
            $0[Self[.level]] = self.level
            $0[Self[.symbol]] = self.symbol
            $0[Self[.github]] = self.github
        }
        u[.setOnInsert]
        {
            $0[Self[.apiLimitLeft]] = self.apiLimitLeft
            $0[Self[.apiKey]] = self.apiKey

            $0[Self[.cookie]] = Int64.random(in: .min ... .max)
        }

        if !self.access.isEmpty
        {
            u[.addToSet]
            {
                $0[Self[.access]] { $0[.each] = self.access }
            }
        }
    }
}
