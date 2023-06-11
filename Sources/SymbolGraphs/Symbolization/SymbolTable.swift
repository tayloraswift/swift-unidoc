import BSONDecoding
import BSONEncoding

@frozen public
struct SymbolTable<Address, Symbol>:Equatable, Sendable
    where Address:SymbolAddress, Symbol:Equatable & Hashable & Sendable
{
    @usableFromInline internal
    var elements:[Symbol]

    @inlinable internal
    init(elements:[Symbol] = [])
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
    func append(_ symbol:Symbol) throws -> Address
    {
        if  let address:Address = self.next
        {
            self.elements.append(symbol)
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
    var startIndex:Int
    {
        self.elements.startIndex
    }
    @inlinable public
    var endIndex:Int
    {
        self.elements.endIndex
    }
    @inlinable public
    subscript(index:Int) -> Symbol
    {
        _read
        {
            yield  self.elements[index]
        }
        _modify
        {
            yield &self.elements[index]
        }
    }
}
extension SymbolTable
{
    @inlinable public
    subscript(address:Address) -> Symbol
    {
        self[address.offset]
    }
}
extension SymbolTable:BSONEncodable, BSONWeakEncodable where Symbol:BSONEncodable
{
    public
    func encode(to field:inout BSON.Field)
    {
        self.elements.encode(to: &field)
    }
}
extension SymbolTable:BSONDecodable where Symbol:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue<some RandomAccessCollection<UInt8>>) throws
    {
        self.init(elements: try .init(bson: bson))
    }
}
