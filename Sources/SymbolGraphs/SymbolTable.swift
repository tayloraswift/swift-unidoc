@frozen public
struct SymbolTable<Address> where Address:SymbolAddress
{
    var identities:[Address.Identity]

    init(identities:[Address.Identity] = [])
    {
        self.identities = identities
    }
}
extension SymbolTable
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

    public mutating
    func callAsFunction(_ identity:Address.Identity) throws -> Address
    {
        if  let address:Address = self.next
        {
            self.identities.append(identity)
            return address
        }
        else
        {
            throw OverflowError.init()
        }
    }
}
