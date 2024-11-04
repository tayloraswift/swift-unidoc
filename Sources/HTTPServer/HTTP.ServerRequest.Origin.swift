import IP

extension HTTP.ServerRequest
{
    @frozen public
    struct Origin:Equatable, Hashable, Sendable
    {
        public
        let owner:IP.Owner
        public
        let ip:IP.V6

        init(owner:IP.Owner, ip:IP.V6)
        {
            self.owner = owner
            self.ip = ip
        }
    }
}
