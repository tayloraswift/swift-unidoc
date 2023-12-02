import BSON
import GitHubAPI

extension GitHub.User:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
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
extension GitHub.User:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            id: try bson[.id].decode(),
            login: try bson[.login].decode(),
            icon: try bson[.icon].decode(),
            node: try bson[.node].decode(),
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
