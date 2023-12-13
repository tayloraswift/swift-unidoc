import BSON
import MongoQL
import UnidocRecords

extension Unidex
{
    @frozen public
    struct User:Equatable, Sendable
    {
        public
        var account:Account
        public
        var level:Level
        public
        var realm:Realm?

        @inlinable public
        init(account:Account, level:Level, realm:Realm? = nil)
        {
            self.account = account
            self.level = level
            self.realm = realm
        }
    }
}
extension Unidex.User
{
    @inlinable public static
    func machine(_ number:Int32 = 0) -> Self
    {
        .init(account: .machine(number), level: .machine)
    }
}
extension Unidex.User:Identifiable
{
    @inlinable public
    var id:Unidex.User.ID { self.account.id }
}
extension Unidex.User:MongoMasterCodingModel
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
    }
}
extension Unidex.User:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.level] = self.level

        switch self.account
        {
        case .machine:          break
        case .github(let user): bson[.github] = user
        }
    }
}
extension Unidex.User:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        switch try bson[.id].decode(to: Unidex.User.ID.self)
        {
        case .machine(let id):
            self = .machine(id)

        case .github:
            self.init(
                account: .github(try bson[.github].decode()),
                level: try bson[.level].decode())
        }
    }
}
