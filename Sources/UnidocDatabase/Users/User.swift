import BSONDecoding
import BSONEncoding

public
struct User
{
    @usableFromInline internal
    var github:GitHubAccount
    @usableFromInline internal
    var role:Role

    @inlinable internal
    init(github:GitHubAccount,
        role:Role = .normal)
    {
        self.github = github
        self.role = role
    }
}
extension User:Identifiable
{
    @inlinable public
    var id:Int { self.github.id }
}
extension User
{
    public
    enum CodingKey:String
    {
        case id = "_id"

        case github = "G"
        case role = "R"
    }
}
extension User:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id

        bson[.github] = self.github
        bson[.role] = self.role
    }
}
extension User:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            github: try bson[.github].decode(),
            role: try bson[.role].decode())
    }
}
