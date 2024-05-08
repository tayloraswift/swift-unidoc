import JSON
import SHA1

extension GitHub
{
    @frozen public
    struct Ref:Equatable, Sendable
    {
        public
        let prefix:Prefix
        public
        let name:String
        public
        var hash:SHA1


        @inlinable public
        init(prefix:Prefix, name:String, hash:SHA1)
        {
            self.prefix = prefix
            self.name = name
            self.hash = hash
        }
    }
}
extension GitHub.Ref:JSONObjectDecodable
{
    public
    enum CodingKey:String, Sendable
    {
        case name

        @available(*, unavailable)
        case node = "node_id"

        case commit
        case prefix
    }

    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(prefix: try json[.prefix].decode(),
            name: try json[.name].decode(),
            hash: try json[.commit].decode(as: Commit.self, with: \.sha))
    }
}
