extension Linker.AddressTable
{
    public
    struct CollisionError:Error, Equatable
    {
        public
        let identity:Identity

        public
        init(identity:Identity)
        {
            self.identity = identity
        }
    }
}
extension Linker.AddressTable.CollisionError:Sendable where Identity:Sendable
{
}
