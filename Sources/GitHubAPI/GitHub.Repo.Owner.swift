import JSON

extension GitHub.Repo
{
    @frozen public
    struct Owner:Equatable, Sendable
    {
        public
        var login:String
        public
        var id:UInt32

        @inlinable public
        init(login:String, id:UInt32)
        {
            self.login = login
            self.id = id
        }
    }
}
extension GitHub.Repo.Owner:JSONObjectDecodable
{
    public
    enum CodingKey:String, Sendable
    {
        case id

        case login

        @available(*, unavailable)
        case node = "node_id"
    }

    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(login: try json[.login].decode(), id: try json[.id].decode())
    }
}
