import IP

extension IP
{
    @frozen public
    struct Origin:Equatable, Hashable, Sendable
    {
        public
        let address:V6
        public
        let owner:Owner

        public
        init(address:V6, owner:Owner)
        {
            self.address = address
            self.owner = owner
        }
    }
}
