import JSON
import SHA1

extension GitHub
{
    @frozen public
    struct Tag:Equatable, Sendable
    {
        public
        let name:String
        public
        var hash:SHA1

        @inlinable public
        init(name:String, hash:SHA1)
        {
            self.name = name
            self.hash = hash
        }
    }
}
extension GitHub.Tag:JSONObjectDecodable
{
    public
    enum CodingKey:String
    {
        case name

        @available(*, unavailable)
        case node = "node_id"

        case commit
    }

    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(
            name: try json[.name].decode(),
            hash: try json[.commit].decode(as: Commit.self, with: \.sha))
    }
}
