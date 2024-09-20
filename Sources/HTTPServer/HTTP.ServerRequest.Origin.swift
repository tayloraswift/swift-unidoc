import IP

extension HTTP.ServerRequest
{
    @frozen public
    struct Origin:Equatable, Hashable, Sendable
    {
        public
        let owner:IP.Owner
        public
        let v6:IP.V6

        init(owner:IP.Owner, v6:IP.V6)
        {
            self.owner = owner
            self.v6 = v6
        }
    }
}
