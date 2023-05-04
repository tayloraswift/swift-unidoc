@frozen public
struct SymbolTable<Address> where Address:SymbolAddress
{
    var identities:[Address.Symbol]

    init(identities:[Address.Symbol] = [])
    {
        self.identities = identities
    }
}
extension SymbolTable
{
    private
    var next:Address?
    {
        if  let int32:Int32 = .init(exactly: self.identities.count)
        {
            return .init(exactly: int32)
        }
        else
        {
            return nil
        }
    }

    public mutating
    func callAsFunction(_ identity:Address.Symbol) throws -> Address
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
