import BSON

extension AccountDatabase.Users
{
    struct RoleView:Equatable, Sendable
    {
        let role:Account.Role

        init(role:Account.Role)
        {
            self.role = role
        }
    }
}
extension AccountDatabase.Users.RoleView:BSONDocumentDecodable
{
    typealias CodingKey = Account.CodingKey

    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(role: try bson[.role].decode())
    }
}
