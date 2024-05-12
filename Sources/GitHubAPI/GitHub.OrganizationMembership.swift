import JSON

extension GitHub
{
    @frozen public
    struct OrganizationMembership
    {
        public
        var state:State
        public
        var role:Role
        public
        var user:Repo.Owner
        public
        var organization:Repo.Owner

        @inlinable public
        init(state:State, role:Role, user:Repo.Owner, organization:Repo.Owner)
        {
            self.state = state
            self.role = role
            self.user = user
            self.organization = organization
        }
    }
}
extension GitHub.OrganizationMembership
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case state
        case role
        case user
        case organization
    }
}
extension GitHub.OrganizationMembership:JSONObjectDecodable
{
    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(state: try json[.state].decode(),
            role: try json[.role].decode(),
            user: try json[.user].decode(),
            organization: try json[.organization].decode())
    }
}
