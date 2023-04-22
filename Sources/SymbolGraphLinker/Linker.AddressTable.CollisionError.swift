extension Linker.AddressTable
{
    public
    struct CollisionError:Error, Equatable
    {
        public
        let identity:Address.Identity

        public
        init(identity:Address.Identity)
        {
            self.identity = identity
        }
    }
}
extension Linker.AddressTable.CollisionError:Sendable where Address.Identity:Sendable
{
}
