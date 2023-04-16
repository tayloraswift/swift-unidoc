extension Linker
{
    struct AddressTable<Identity> where Identity:Hashable
    {
        private
        var identities:[Identity]
        private
        var addresses:[Identity: UInt32]

        init()
        {
            self.identities = []
            self.addresses = [:]
        }
    }
}
extension Linker.AddressTable:Sendable where Identity:Sendable
{
}
extension Linker.AddressTable
{
    @discardableResult
    mutating
    func append(_ identity:Identity) throws -> UInt32
    {
        guard let address:UInt32 = .init(exactly: self.identities.count)
        else
        {
            throw OverflowError.init()
        }
        guard address == { $0 }(&self.addresses[identity, default: address])
        else
        {
            throw CollisionError.init(identity: identity)
        }

        self.identities.append(identity)
        return address
    }
    mutating
    func address(_ identity:Identity) throws -> UInt32
    {
        guard let address:UInt32 = .init(exactly: self.identities.count)
        else
        {
            throw OverflowError.init()
        }
        switch ({ $0 }(&self.addresses[identity, default: address]))
        {
        case address:
            self.identities.append(identity)
            return address
        
        case let address:
            return address
        }
    }
}
