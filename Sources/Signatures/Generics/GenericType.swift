@frozen public
enum GenericType<Scalar>
{
    case nominal(Scalar)
    case complex(String)
}
extension GenericType:Equatable where Scalar:Equatable
{
}
extension GenericType:Hashable where Scalar:Hashable
{
}
extension GenericType:Sendable where Scalar:Sendable
{
}
extension GenericType:Comparable where Scalar:Comparable
{
}
extension GenericType
{
    @inlinable public
    var nominal:Scalar?
    {
        switch self
        {
        case .nominal(let type):    type
        case .complex:              nil
        }
    }
    @inlinable public
    func map<T>(_ transform:(Scalar) throws -> T) rethrows -> GenericType<T>
    {
        switch self
        {
        case .nominal(let type):    .nominal(try transform(type))
        case .complex(let type):    .complex(type)
        }
    }
    @inlinable public
    func flatMap<T>(_ transform:(Scalar) throws -> T?) rethrows -> GenericType<T>?
    {
        switch self
        {
        case .nominal(let type):    try transform(type).map { .nominal($0) }
        case .complex(let type):    .complex(type)
        }
    }
}
