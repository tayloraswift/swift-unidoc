import JSON

extension GitHub.Repo
{
    @frozen public
    struct Owner:Identifiable, Equatable, Sendable
    {
        public
        let id:Int32
        public
        var login:String
        public
        var node:String

        @inlinable public
        init(id:Int32, login:String, node:String)
        {
            self.id = id
            self.login = login
            self.node = node
        }
    }
}
extension GitHub.Repo.Owner:JSONObjectDecodable
{
    public
    enum CodingKey:String
    {
        case id
        case login
        case node = "node_id"
    }

    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(id: try json[.id].decode(),
            login: try json[.login].decode(),
            node: try json[.node].decode())
    }
}
