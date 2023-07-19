public
enum Generic<T>
{
    case value(T)
}

extension Generic:Equatable where T:Equatable
{
}
extension Generic:Hashable where T:Hashable
{
}
