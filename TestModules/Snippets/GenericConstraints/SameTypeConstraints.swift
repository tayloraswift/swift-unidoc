public
enum Namespace
{
    public
    enum E<T>
    {
        case e(T)
    }
}
public
enum Generic<T>
{
}
extension Generic:Sendable where T == Namespace.E<Int>
{
}
