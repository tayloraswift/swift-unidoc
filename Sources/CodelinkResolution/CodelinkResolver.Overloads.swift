extension CodelinkResolver
{
    @frozen public
    enum Overloads:Equatable, Hashable
    {
        case one  (Overload)
        case some([Overload])
    }
}
extension CodelinkResolver.Overloads:Sendable where Address:Sendable
{
}
extension CodelinkResolver.Overloads
{
    init(filtering overloads:[CodelinkResolver<Address>.Overload],
        where predicate:(CodelinkResolver<Address>.Overload) throws -> Bool) rethrows
    {
        self = .some([])
        for overload:CodelinkResolver<Address>.Overload in overloads where
            try predicate(overload)
        {
            self.overload(with: overload)
        }
    }

    @inlinable public mutating
    func overload(with overload:CodelinkResolver<Address>.Overload)
    {
        switch self
        {
        case .one(let other):
            self = .some([other, overload])

        case .some(var others):
            if  others.isEmpty
            {
                self = .one(overload)
            }
            else
            {
                self = .some([])
                others.append(overload)
                self = .some(others)
            }
        }
    }
}
