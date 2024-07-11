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
extension GitHub.Repo.Owner:CustomStringConvertible
{
    /// This conformance witnessed to idiot-proof string interpolation mistakes, as this type
    /// sometimes appears in an `owner` field that is otherwise a ``String``. Prefer
    /// interpolating ``login`` directly!
    @inlinable public
    var description:String { self.login }
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
