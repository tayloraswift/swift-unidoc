extension Linker
{
    struct AddressTable<Address> where Address:SymbolAddress
    {
        private
        var identities:[Address.Identity]
        private
        var addresses:[Address.Identity: Address]

        init()
        {
            self.identities = []
            self.addresses = [:]
        }
    }
}
extension Linker.AddressTable:Sendable where Address.Identity:Sendable
{
}
extension Linker.AddressTable
{
    private
    var next:Address?
    {
        if  let uint32:UInt32 = .init(exactly: self.identities.count)
        {
            return .init(exactly: uint32)
        }
        else
        {
            return nil
        }
    }
}
extension Linker.AddressTable
{
    mutating
    func append(_ identity:Address.Identity) throws -> Address
    {
        guard let address:Address = self.next
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
    func address(_ identity:Address.Identity) throws -> Address
    {
        guard let address:Address = self.next
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
extension Linker.AddressTable
{
    subscript(identity:Address.Identity) -> Address?
    {
        self.addresses[identity]
    }
}
