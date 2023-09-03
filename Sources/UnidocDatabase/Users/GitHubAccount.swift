import BSONDecoding
import BSONEncoding

@usableFromInline internal
struct GitHubAccount
{
    @usableFromInline internal
    var id:Int

    @usableFromInline internal
    var credentials:GitHubCredentials?
    @usableFromInline internal
    var username:String?
    @usableFromInline internal
    var icon:String?

    @usableFromInline internal
    var repositories:Int?
    @usableFromInline internal
    var followers:Int?
    @usableFromInline internal
    var location:String?
    @usableFromInline internal
    var company:String?
    @usableFromInline internal
    var blog:String?
    @usableFromInline internal
    var bio:String?

    @inlinable internal
    init(id:Int,
        credentials:GitHubCredentials? = nil,
        username:String? = nil,
        icon:String? = nil,
        repositories:Int? = nil,
        followers:Int? = nil,
        location:String? = nil,
        company:String? = nil,
        blog:String? = nil,
        bio:String? = nil)
    {
        self.id = id
        self.credentials = credentials
        self.username = username
        self.repositories = repositories
        self.followers = followers
        self.location = location
        self.company = company
        self.blog = blog
        self.bio = bio
    }
}
extension GitHubAccount
{
    @usableFromInline internal
    enum CodingKey:String
    {
        case id = "_id"

        case credentials = "C"
        case username = "U"
        case icon = "I"

        case repositories = "R"
        case followers = "F"
        case location = "L"
        case company = "O"
        case blog = "B"
        case bio = "A"
    }
}
extension GitHubAccount:BSONDocumentEncodable
{
    @usableFromInline internal
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id

        bson[.credentials] = self.credentials
        bson[.username] = self.username
        bson[.icon] = self.icon

        bson[.repositories] = self.repositories
        bson[.followers] = self.followers
        bson[.location] = self.location
        bson[.company] = self.company
        bson[.blog] = self.blog
        bson[.bio] = self.bio
    }
}
extension GitHubAccount:BSONDocumentDecodable
{
    @inlinable internal
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(),
            credentials: try bson[.credentials]?.decode(),
            username: try bson[.username]?.decode(),
            icon: try bson[.icon]?.decode(),
            repositories: try bson[.repositories]?.decode(),
            followers: try bson[.followers]?.decode(),
            location: try bson[.location]?.decode(),
            company: try bson[.company]?.decode(),
            blog: try bson[.blog]?.decode(),
            bio: try bson[.bio]?.decode())
    }
}
