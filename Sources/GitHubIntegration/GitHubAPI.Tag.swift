import JSON
import SHA1

extension GitHubAPI
{
    @frozen public
    struct Tag:Equatable, Sendable
    {
        public
        let name:String
        public
        var node:String
        public
        var hash:SHA1

        @inlinable public
        init(name:String, node:String, hash:SHA1)
        {
            self.name = name
            self.node = node
            self.hash = hash
        }
    }
}
extension GitHubAPI.Tag:JSONObjectDecodable
{
    public
    enum CodingKey:String
    {
        case name
        case node = "node_id"
        case commit
    }

    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(
            name: try json[.name].decode(),
            node: try json[.node].decode(),
            hash: try json[.commit].decode(as: Commit.self, with: \.sha))
    }
}
