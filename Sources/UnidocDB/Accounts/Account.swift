import BSONDecoding
import BSONEncoding
import GitHubIntegration
import MongoQL

public
struct Account:Identifiable, Sendable
{
    public
    let id:ID

    public
    var role:Role
    public
    var user:GitHubAPI.User?

    @inlinable internal
    init(id:ID, role:Role, user:GitHubAPI.User? = nil)
    {
        self.id = id

        self.role = role
        self.user = user
    }
}
extension Account
{
    @inlinable public static
    func github(user:GitHubAPI.User, role:Role) -> Self
    {
        .init(id: .github(user.id), role: role, user: user)
    }
}
extension Account:MongoMasterCodingModel
{
    public
    enum CodingKey:String
    {
        case id = "_id"

        /// The session cookie associated with this account, if logged in. This is generated
        /// randomly in ``AccountDatabase.update(account:with:)``.
        case cookie

        case role
        case user
    }
}
extension Account:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id

        bson[.user] = self.user
        bson[.role] = self.role
    }
}
extension Account:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(),
            role: try bson[.role].decode(),
            user: try bson[.user].decode())
    }
}
