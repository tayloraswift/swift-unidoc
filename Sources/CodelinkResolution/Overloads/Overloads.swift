@frozen public
enum Overloads<Address>:Equatable, Hashable, Sendable
    where Address:Equatable & Hashable & Sendable
{
    case one  (Overload<Address>)
    case many([Overload<Address>])
}
extension Overloads
{
    init?(_ overloads:Overload<Address>.Accumulator)
    {
        switch overloads
        {
        case .none:                 return nil
        case .one(let overload):    self = .one(overload)
        case .many(let overloads):  self = .many(overloads)
        }
    }
}
