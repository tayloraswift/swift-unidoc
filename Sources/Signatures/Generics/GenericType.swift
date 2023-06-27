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
        case .nominal(let type):    return type
        case .complex:              return nil
        }
    }
    @inlinable public
    func map<T>(_ transform:(Scalar) throws -> T) rethrows -> GenericType<T>
    {
        switch self
        {
        case .nominal(let type):    return .nominal(try transform(type))
        case .complex(let type):    return .complex(type)
        }
    }
    @inlinable public
    func flatMap<T>(_ transform:(Scalar) throws -> T?) rethrows -> GenericType<T>?
    {
        switch self
        {
        case .nominal(let type):    return try transform(type).map { .nominal($0) }
        case .complex(let type):    return .complex(type)
        }
    }
}
