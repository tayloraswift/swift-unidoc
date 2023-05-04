import BSONDecoding
import BSONEncoding

@frozen public
struct SymbolTable<Address> where Address:SymbolAddress
{
    @usableFromInline internal
    var identities:[Address.Symbol]

    @inlinable internal
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
extension SymbolTable:BSONEncodable, BSONFieldEncodable where Address.Symbol:BSONEncodable
{
    public
    func encode(to field:inout BSON.Field)
    {
        self.identities.encode(to: &field)
    }
}
extension SymbolTable:BSONDecodable where Address.Symbol:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue<some RandomAccessCollection<UInt8>>) throws
    {
        self.init(identities: try .init(bson: bson))
    }
}
