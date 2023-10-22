import JSON

extension GitHub.Repo
{
    @frozen public
    struct Owner:Equatable, Sendable
    {
        public
        var login:String

        @inlinable public
        init(login:String)
        {
            self.login = login
        }
    }
}
extension GitHub.Repo.Owner:JSONObjectDecodable
{
    public
    enum CodingKey:String
    {
        @available(*, unavailable)
        case id

        case login

        @available(*, unavailable)
        case node = "node_id"
    }

    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(login: try json[.login].decode())
    }
}
