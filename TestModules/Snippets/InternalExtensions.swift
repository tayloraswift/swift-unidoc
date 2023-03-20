public
struct Struct<T>
{
}

public
protocol Protocol<U>
{
    associatedtype U:Sequence
}
extension Protocol
{
    public
    var unconstrained:Void { return }
}
extension Protocol where U:BidirectionalCollection
{
    public
    var constrained:Void { return }
}

extension Struct:Protocol where T:Collection
{
    public
    typealias U = T
}
