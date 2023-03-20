public
protocol Protocol<T>
{
    associatedtype T where T:Sequence
}

public
struct Struct<T> where T:Sequence
{
}
