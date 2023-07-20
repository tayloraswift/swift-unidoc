public
enum Namespace
{
    public
    class NestedClass
    {
        init() {}
    }
}
public
enum Generic<T>
{
}
extension Generic:Sendable where T:Namespace.NestedClass
{
}
