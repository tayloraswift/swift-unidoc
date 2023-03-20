public
protocol Protocol<T>
{
    associatedtype T where T:Sequence
}

public
struct Struct<T> where T:Sequence
{
}

extension Protocol where T:Equatable
{
    public
    func `internal`(_:T) where T:Sendable
    {
    }
}
extension Struct where T:Equatable
{
    public
    func `internal`(_:T) where T:Sendable
    {
    }
}
