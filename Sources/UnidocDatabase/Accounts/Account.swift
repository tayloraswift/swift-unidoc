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
    var session:Int64?
    public
    var role:Role
    public
    var user:GitHubAPI.User?

    @inlinable internal
    init(id:ID, session:Int64?, role:Role, user:GitHubAPI.User? = nil)
    {
        self.id = id

        self.session = session
        self.role = role
        self.user = user
    }
}
extension Account
{
    @inlinable public static
    func github(user:GitHubAPI.User, role:Role) -> Self
    {
        .init(id: .github(user.id),
            session: Int64.random(in: .min ... .max),
            role: role,
            user: user)
    }
}
extension Account:MongoMasterCodingModel
{
    public
    enum CodingKey:String
    {
        case id = "_id"
        case session
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

        bson[.session] = self.session
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
            session: try bson[.session].decode(),
            role: try bson[.role].decode(),
            user: try bson[.user].decode())
    }
}
