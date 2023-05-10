import BSONDecoding
import BSONEncoding

public
protocol SymbolAddress:Equatable, Hashable, Comparable, Strideable, Sendable
{
    associatedtype Symbol:Equatable, Hashable, Sendable

    init(value:Int32)
    var value:Int32 { get }
}
extension SymbolAddress where Self:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        lhs.value < rhs.value
    }
}
extension SymbolAddress where Self:Strideable
{
    @inlinable public
    func advanced(by stride:Int) -> Self
    {
        .init(value: self.value.advanced(by: stride))
    }
    @inlinable public
    func distance(to other:Self) -> Int
    {
        self.value.distance(to: other.value)
    }
}
extension SymbolAddress where Self:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        return "0x\(String.init(self.value, radix: 16, uppercase: true))"
    }
}
extension SymbolAddress where Self:BSONEncodable
{
    public
    func encode(to field:inout BSON.Field)
    {
        self.value.encode(to: &field)
    }
}
extension SymbolAddress where Self:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue<some RandomAccessCollection<UInt8>>) throws
    {
        self = try bson.cast
        {
            if case .int32(let int32) = $0
            {
                return .init(value: int32)
            }
            else
            {
                return nil
            }
        }
    }
}
