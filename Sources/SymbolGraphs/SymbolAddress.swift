import BSONDecoding
import BSONEncoding

public
protocol SymbolAddress:Equatable, Hashable, Comparable, Sendable
{
    associatedtype Identity:Equatable, Hashable, Sendable

    init?(exactly:Int32)

    var value:Int32 { get }
}
extension SymbolAddress
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        lhs.value < rhs.value
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
                return .init(exactly: int32)
            }
            else
            {
                return nil
            }
        }
    }
}
