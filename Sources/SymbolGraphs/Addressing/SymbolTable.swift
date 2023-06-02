import BSONDecoding
import BSONEncoding

@frozen public
struct SymbolTable<Address>:Equatable, Sendable where Address:SymbolAddress
{
    @usableFromInline internal
    var elements:[Address.Symbol]

    @inlinable internal
    init(elements:[Address.Symbol] = [])
    {
        self.elements = elements
    }
}
extension SymbolTable
{
    private
    var next:Address?
    {
        let count:Int = self.elements.count
        if  0 ... 0x00_ff_ff_ff ~= count
        {
            return .init(value: .init(count))
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
            self.elements.append(identity)
            return address
        }
        else
        {
            throw OverflowError.init()
        }
    }
}
extension SymbolTable:RandomAccessCollection
{
    @inlinable public
    var startIndex:ScalarAddress
    {
        .init(value: .init(self.elements.startIndex))
    }
    @inlinable public
    var endIndex:ScalarAddress
    {
        .init(value: .init(self.elements.endIndex))
    }
    @inlinable public
    subscript(address:ScalarAddress) -> Address.Symbol
    {
        _read
        {
            yield  self.elements[.init(address.value)]
        }
        _modify
        {
            yield &self.elements[.init(address.value)]
        }
    }
}
extension SymbolTable:BSONEncodable, BSONWeakEncodable where Address.Symbol:BSONEncodable
{
    public
    func encode(to field:inout BSON.Field)
    {
        self.elements.encode(to: &field)
    }
}
extension SymbolTable:BSONDecodable where Address.Symbol:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue<some RandomAccessCollection<UInt8>>) throws
    {
        self.init(elements: try .init(bson: bson))
    }
}
