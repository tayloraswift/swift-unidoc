public
protocol SymbolAddress:Equatable, Hashable, Comparable, Sendable
{
    associatedtype Identity:Equatable, Hashable, Sendable

    init?(exactly:UInt32)

    var value:UInt32 { get }
}
extension SymbolAddress
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        lhs.value < rhs.value
    }
}
