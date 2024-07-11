import JSON

extension GitHub
{
    @frozen public
    struct UserInvite:Identifiable, Equatable, Sendable
    {
        public
        let id:UInt32
        /// The user’s @-name.
        public
        var login:String
        /// The user’s icon URL.
        public
        var icon:String
        /// The user’s node id within the GraphQL API.
        public
        var node:Node

        @inlinable public
        init(id:UInt32, login:String, icon:String, node:Node)
        {
            self.id = id
            self.login = login
            self.icon = icon
            self.node = node
        }
    }
}
extension GitHub.UserInvite:JSONObjectDecodable
{
    public
    init(json:JSON.ObjectDecoder<GitHub.User.CodingKey>) throws
    {
        self.init(id: try json[.id].decode(),
            login: try json[.login].decode(),
            icon: try json[.avatar_url].decode(),
            node: try json[.node_id].decode())
    }
}
