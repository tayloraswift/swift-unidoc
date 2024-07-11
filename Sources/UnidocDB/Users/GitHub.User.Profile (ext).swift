import BSON
import GitHubAPI
import UnidocRecords

extension GitHub.User.Profile
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case login = "U"
        case icon = "P"
        case node = "Q"
        case nodeLegacy = "Z"
        case location = "L"
        case hireable = "H"
        case company = "O"
        case email = "E"
        case name = "N"
        case blog = "B"
        case bio = "A"
        case x = "X"
        case publicRepos = "R"
        case publicGists = "G"
        case followers = "I"
        case following = "J"
        case created = "C"
        case updated = "M"
    }
}
extension GitHub.User.Profile:BSONDocumentEncodable, BSONEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.login] = self.login
        bson[.icon] = self.icon
        bson[.node] = self.node
        bson[.location] = self.location
        bson[.hireable] = self.hireable
        bson[.company] = self.company
        bson[.email] = self.email
        bson[.name] = self.name
        bson[.blog] = self.blog
        bson[.bio] = self.bio
        bson[.x] = self.x
        bson[.publicRepos] = self.publicRepos
        bson[.publicGists] = self.publicGists
        bson[.followers] = self.followers
        bson[.following] = self.following
        bson[.created] = self.created
        bson[.updated] = self.updated
    }
}
extension GitHub.User.Profile:BSONDocumentDecodable, BSONDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            login: try bson[.login].decode(),
            icon: try bson[.icon].decode(),
            //  Note: type of this field changed from String to Binary Array
            node: try bson[.node]?.decode() ?? .init(bson[.nodeLegacy].decode()),
            location: try bson[.location]?.decode(),
            hireable: try bson[.hireable]?.decode(),
            company: try bson[.company]?.decode(),
            email: try bson[.email]?.decode(),
            name: try bson[.name]?.decode(),
            blog: try bson[.blog]?.decode(),
            bio: try bson[.bio]?.decode(),
            x: try bson[.x]?.decode(),
            publicRepos: try bson[.publicRepos].decode(),
            publicGists: try bson[.publicGists].decode(),
            followers: try bson[.followers].decode(),
            following: try bson[.following].decode(),
            created: try bson[.created].decode(),
            updated: try bson[.updated].decode())
    }
}
